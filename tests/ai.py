"""AI 插件迁移回归：用本地候选驱动真实渲染器与键盘映射，不发送网络请求。

运行：uv run --no-project --with pynvim==0.6.0 python tests/ai.py
NVIM_BIN / XDG_CONFIG_HOME / XDG_DATA_HOME 可选择隔离配置。
"""

from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import tempfile
import time

import pynvim


def run() -> None:
    binary = os.environ.get("NVIM_BIN") or shutil.which("nvim")
    if not binary:
        raise RuntimeError("nvim not found; set NVIM_BIN")
    checks = []
    with tempfile.TemporaryDirectory(prefix="nvim-ai-test-") as directory:
        fixture = Path(directory) / "fixture.txt"
        fixture.write_text("")
        os.environ["XDG_STATE_HOME"] = str(Path(directory) / "state")
        os.environ["XDG_CACHE_HOME"] = str(Path(directory) / "cache")
        nvim = pynvim.attach(
            "child",
            argv=[
                binary,
                "--headless",
                "--embed",
                "--cmd",
                "let g:codeium_enabled = v:false",
                str(fixture),
            ],
        )
        nvim.ui_attach(120, 40, rgb=True)

        def lua(code, *args):
            return nvim.exec_lua(code, *args)

        def until(predicate, label):
            end = time.monotonic() + 5
            while time.monotonic() < end:
                if predicate():
                    return
                time.sleep(0.03)
            raise AssertionError(f"Timed out: {label}")

        def reset(text=""):
            nvim.input("<Esc>")
            until(lambda: nvim.eval("mode()") == "n", "normal mode")
            lua("require('neocodeium').clear()")
            nvim.current.buffer[:] = [text]
            nvim.current.window.cursor = (1, max(len(text) - 1, 0))
            nvim.input("A")
            until(lambda: nvim.eval("mode()") == "i", "insert mode")
            time.sleep(0.1)

        def seed(*texts):
            # 仅替换网络响应数据，渲染、候选切换、接受与清理使用插件真实实现。
            lua(
                """
                local texts = ...
                local state = require("neocodeium.state")
                local pos=vim.api.nvim_win_get_cursor(0)
                local line=vim.api.nvim_get_current_line()
                state.active=true
                state.pending=false
                state.matching=false
                state.pos={pos[1]-1,pos[2]}
                state.curline_text=line
                local items={}
                for i,text in ipairs(texts) do
                    items[i]={
                        completion={text=text,completionId="local-test-"..i},
                        completionParts={{type="COMPLETION_PART_TYPE_INLINE",
                            prefix=line,text=text,line=pos[1]-1}},
                    }
                end
                state.data={index=1,items=items}
                require("neocodeium.completer"):update()
                """,
                list(texts),
            )

        def marks():
            return lua(
                "return vim.api.nvim_buf_get_extmarks(0,"
                "vim.api.nvim_create_namespace('neocodeium_compl'),0,-1,{})"
            )

        try:
            lua("require('lazy').load({plugins={'neocodeium','blink.cmp'}})")
            assert not lua("return require('neocodeium.options').options.enabled")
            assert lua("return require('neocodeium.server').pid == nil")
            assert lua("return require('neocodeium.server').port == nil")
            checks.append("disabled_ai_has_no_server_or_network")
            # 不让另一套补全菜单影响纯 AI 键位测试。
            lua("require('blink.cmp.config').enabled=function() return false end")
            assert (
                lua("return vim.api.nvim_get_hl(0,{name='NeoCodeiumSuggestion'}).fg")
                == 0x808080
            )
            assert not lua("return require('neocodeium.options').options.show_label")
            checks.append("original_gray_suggestion_without_extra_label")

            reset()
            seed("alpha", "beta")
            assert marks()
            nvim.input("<A-n>")
            until(
                lambda: lua("return require('neocodeium.state').data.index") == 2,
                "next suggestion",
            )
            nvim.input("<A-N>")
            until(
                lambda: lua("return require('neocodeium.state').data.index") == 1,
                "previous suggestion",
            )
            nvim.input("<A-]>")
            until(
                lambda: lua("return require('neocodeium.state').data.index") == 2,
                "legacy next alias",
            )
            nvim.input("<A-[>")
            until(
                lambda: lua("return require('neocodeium.state').data.index") == 1,
                "legacy previous alias",
            )
            nvim.input("<C-g>")
            until(lambda: nvim.current.buffer[0] == "alpha", "accept via Ctrl-G")
            checks.append("accept_cycle_and_legacy_aliases")

            reset()
            seed("existing", "alternative")
            # 只替换请求发送端；即使已有候选，Alt-反斜杠也必须请求，而不是只切换。
            lua("""
                local completer=require("neocodeium.completer")
                ai_manual_original=completer.request
                ai_manual_requests=0
                completer.request=function()
                    ai_manual_requests=ai_manual_requests+1
                end
            """)
            try:
                nvim.input("<A-Bslash>")
                until(
                    lambda: lua("return ai_manual_requests") == 1,
                    "manual refresh request",
                )
                assert lua("return require('neocodeium.state').data.index ~= 2")
            finally:
                lua("""
                    require("neocodeium.completer").request=ai_manual_original
                    ai_manual_original=nil
                    ai_manual_requests=nil
                """)
            checks.append("manual_request_refreshes_existing_candidates")

            reset()
            seed("discard")
            nvim.input("<C-x>")
            until(lambda: not marks(), "clear suggestion")
            assert nvim.current.buffer[0] == ""
            checks.append("clear_without_editing_text")

            reset("x")
            lua("vim.bo.expandtab=false")
            nvim.input("<C-g>")
            until(lambda: nvim.current.buffer[0] == "x\t", "Tab fallback")
            reset("x")
            # 服务可能返回空候选数组；它也必须走原来的 Tab 回退。
            lua("require('neocodeium.state').data={index=1,items={}}")
            nvim.input("<C-g>")
            until(lambda: nvim.current.buffer[0] == "x\t", "empty response fallback")
            checks.append("no_candidate_and_empty_response_tab_fallback")

            reset("x")
            lua("vim.g.codeium_tab_fallback='fallback'")
            nvim.input("<C-g>")
            until(lambda: nvim.current.buffer[0] == "xfallback", "custom fallback")
            lua("vim.g.codeium_tab_fallback=nil")
            checks.append("custom_fallback_preserved")

            reset()
            nvim.command("iabbrev zz expanded")
            nvim.input("zz")
            until(lambda: nvim.current.buffer[0] == "zz", "abbreviation input")
            seed("ignore")
            nvim.input("<C-]>")
            until(lambda: nvim.current.buffer[0] == "expanded", "Ctrl-] abbreviation")
            assert not marks()
            checks.append("ctrl_bracket_clears_then_expands_abbreviation")

            nvim.input("<Esc>")
            nvim.command("Codeium Manual")
            assert lua("return require('neocodeium.options').options.manual")
            nvim.command("CodeiumAuto")
            assert not lua("return require('neocodeium.options').options.manual")
            nvim.command("Codeium DisableBuffer")
            assert lua("return vim.b.neocodeium_enabled == false")
            nvim.command("Codeium EnableBuffer")
            assert lua("return vim.b.neocodeium_enabled == true")
            nvim.command("CodeiumDisable")
            assert not lua("return require('neocodeium.options').options.enabled")
            assert lua("return require('neocodeium.server').pid == nil")
            checks.append("legacy_commands_and_disabled_lifecycle")

            # 开关命令交叉使用时必须同步旧变量，server.run 替身保证本地测试零网络。
            lua("""
                local server=require("neocodeium.server")
                ai_server_run=server.run
                ai_server_starts=0
                server.run=function() ai_server_starts=ai_server_starts+1 end
            """)
            try:
                nvim.command("NeoCodeium enable")
                assert lua("return vim.g.codeium_enabled == true")
                assert lua("return require('neocodeium.options').options.enabled")
                assert lua("return require('neocodeium.options').options.filter(0)")
                assert lua("return ai_server_starts") == 1
                nvim.command("NeoCodeium disable")
                assert lua("return vim.g.codeium_enabled == false")
                nvim.command("CodeiumEnable")
                assert lua("return vim.g.codeium_enabled == true")
                assert lua("return require('neocodeium.options').options.filter(0)")
                assert lua("return ai_server_starts") == 2

                nvim.command("CodeiumDisableBuffer")
                assert lua("return vim.b.codeium_enabled == false")
                nvim.command("NeoCodeium enable_buffer")
                assert lua("return vim.b.codeium_enabled == true")
                assert lua("return require('neocodeium.options').options.filter(0)")
                nvim.command("NeoCodeium disable_buffer")
                assert lua("return vim.b.codeium_enabled == false")
                nvim.command("CodeiumEnableBuffer")
                assert lua("return vim.b.codeium_enabled == true")
                assert lua("return require('neocodeium.options').options.filter(0)")

                # 在事件返回后立刻换缓冲区，原缓冲区的开关仍应正确、独立地保存。
                original_buffer = nvim.current.buffer.number
                nvim.command("NeoCodeium disable_buffer")
                lua("vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(true,false))")
                assert lua(
                    "return vim.b[...].codeium_enabled == false", original_buffer
                )
                assert lua("return vim.b.codeium_enabled == nil")
                lua("vim.api.nvim_set_current_buf(...)", original_buffer)
                nvim.command("NeoCodeium enable_buffer")
                nvim.command("CodeiumDisable")
                assert lua("return vim.g.codeium_enabled == false")
                assert not lua("return require('neocodeium.state').active")
                assert lua("return require('neocodeium.server').pid == nil")
                checks.append("cross_command_global_and_buffer_switches")
            finally:
                lua(
                    "require('neocodeium.server').run=ai_server_run; ai_server_run=nil; ai_server_starts=nil"
                )

            nvim.command("checkhealth vim.deprecated")
            health = "\n".join(nvim.current.buffer[:])
            assert "/neocodeium/" not in health, health
            messages = nvim.command_output("messages")
            assert "Error executing" not in messages, messages
            print(
                json.dumps(
                    {"passed": checks, "cloud_request_sent": False}, ensure_ascii=False
                )
            )
        finally:
            try:
                nvim.command("qa!")
            except Exception:
                pass


if __name__ == "__main__":
    run()
