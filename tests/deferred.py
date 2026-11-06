"""验证手动命令入口，避免只测试启动而漏掉终端和差异面板的旧 API。"""

from __future__ import annotations
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import pynvim


def run():
    executable = os.environ.get("NVIM_BIN") or shutil.which("nvim")
    if not executable:
        raise RuntimeError("Set NVIM_BIN or add nvim to PATH")
    checks = {}
    with tempfile.TemporaryDirectory(prefix="nvim-deferred-test-") as temp:
        root = Path(temp)
        repo = root / "project"
        repo.mkdir()
        path = repo / "example.txt"
        path.write_text("first line\nsecond line\n")

        def git(*args):
            subprocess.run(
                ["git", "-c", "core.hooksPath=/dev/null", "-C", str(repo), *args],
                check=True,
                capture_output=True,
            )

        git("init", "-q")
        git("add", "example.txt")
        git(
            "-c",
            "user.name=Neovim Test",
            "-c",
            "user.email=nvim-test@example.invalid",
            "commit",
            "-qm",
            "Fixture commit",
        )
        path.write_text("first line\nmodified line\n")
        saved = {
            key: os.environ.get(key) for key in ["XDG_STATE_HOME", "XDG_CACHE_HOME"]
        }
        os.environ["XDG_STATE_HOME"] = str(root / "state")
        os.environ["XDG_CACHE_HOME"] = str(root / "cache")
        n = pynvim.attach(
            "child",
            argv=[
                executable,
                "--headless",
                "--embed",
                "--cmd",
                "let g:codeium_enabled = v:false",
                "--cmd",
                "lua _G.original_validate = vim.validate",
                str(path),
            ],
        )
        n.ui_attach(160, 50, rgb=True)

        def lua(code, *args):
            return n.exec_lua(code, *args)

        def until(fn, label):
            end = time.monotonic() + 15
            while time.monotonic() < end:
                value = fn()
                if value:
                    return value
                time.sleep(0.1)
            raise AssertionError("Timed out waiting for " + label)

        try:
            n.command("cd " + n.funcs.fnameescape(str(repo)))
            until(lambda: lua("return package.loaded.lualine ~= nil"), "lualine")
            lua("require('lualine').refresh({force=true})")
            line = lua(
                "return vim.api.nvim_eval_statusline(vim.wo.statusline,{winid=0}).str"
            )
            assert "example.txt" in line, line
            checks["lualine_render_and_refresh"] = line
            # 补丁只变换指定模块，重复注册/重复编译结果一致；未知源码必须明确失败。
            lua("""
                local patches=require("config.plugin_patches")
                for _,name in ipairs({"toggleterm","diffview"}) do
                    local plan=require("config.compat."..name)
                    local plugin=require("lazy.core.config").plugins[name..".nvim"]
                    patches.register(plugin,plan)
                    patches.register(plugin,plan)
                    for _,patch in ipairs(plan.modules) do
                        local file=assert(io.open(plugin.dir.."/"..patch.path,"rb"))
                        local source=file:read("*a")
                        file:close()
                        local first=patches.transform(source,patch)
                        assert(first==patches.transform(source,patch))
                        assert(loadstring(first))
                        local ok,err=pcall(patches.transform,source.." ",patch)
                        assert(not ok and err:find("SHA256",1,true))
                        local changed=vim.deepcopy(patch)
                        changed.replacements[1].before="not the expected source"
                        ok,err=pcall(patches.transform,source,changed)
                        assert(not ok and err:find("唯一匹配",1,true))
                        changed.replacements[1].before=" "
                        ok,err=pcall(patches.transform,source,changed)
                        assert(not ok and err:find("唯一匹配",1,true))
                    end
                end
                assert(vim.validate==_G.original_validate,"Global validator was changed")
            """)
            checks["patch_idempotence_and_fail_closed"] = True
            lua("""
                local function rejects(fn,key)
                    local ok,err=pcall(fn)
                    assert(not ok and tostring(err):find(key,1,true),tostring(err))
                end
                local term=require("toggleterm")
                rejects(function() term.exec_command({}) end,"args")
                rejects(function() term.exec(123) end,"cmd")
                rejects(function() term.exec("printf test","bad") end,"num")
                rejects(function()
                    term.send_lines_to_terminal(12,true,{args="1"})
                end,"selection_type")
                local Panel=require("diffview.ui.panel").Panel
                local split={
                    config_producer={type="split",position="left",relative="editor",width=30,win_opts={}},
                    state={},
                    get_default_config=function() return {} end,
                }
                assert(Panel.get_config(split).width==30 and split.state.form=="column")
                split.config_producer.width="wide"
                rejects(function() Panel.get_config(split) end,"width")
                local floating={
                    config_producer={type="float",relative="editor",width=20,height=5,row=1,col=2,win_opts={},border="single"},
                    state={},
                    get_default_config=function() return {} end,
                }
                assert(Panel.get_config(floating).border=="single")
                floating.config_producer.border={"one entry"}
                rejects(function() Panel.get_config(floating) end,"border")
            """)
            checks["argument_validation_preserved"] = True
            # 清除模块缓存再 require，确认 preload 会重新应用补丁，而非依赖一次性修改。
            lua("""
                for _,name in ipairs({"toggleterm","diffview.ui.panel","diffview.vcs.adapters.git"}) do
                    local old=require(name)
                    package.loaded[name]=nil
                    local new=require(name)
                    assert(type(new)=="table" and new~=old)
                end
                assert(vim.validate==_G.original_validate)
            """)
            checks["patched_modules_reload"] = True
            n.command("ToggleTerm")
            term = until(
                lambda: lua(
                    "local t=require('toggleterm.terminal').get(1); return t and t:is_open() and {bufnr=t.bufnr,job_id=t.job_id}"
                ),
                "terminal opens",
            )
            n.api.chan_send(term["job_id"], "printf 'NVIM_TERMINAL_TEST_OK\\n'\n")
            until(
                lambda: "NVIM_TERMINAL_TEST_OK"
                in "\n".join(n.buffers[term["bufnr"]][:]),
                "terminal command output",
            )
            n.command("stopinsert")
            n.command("ToggleTerm")
            until(
                lambda: lua(
                    "return not require('toggleterm.terminal').get(1):is_open()"
                ),
                "terminal closes",
            )
            n.command("ToggleTerm")
            until(
                lambda: lua("return require('toggleterm.terminal').get(1):is_open()"),
                "same terminal reopens",
            )
            n.command("stopinsert")
            n.command("ToggleTerm")
            checks["toggleterm_open_close_reopen"] = True
            n.command("TermExec cmd='echo NVIM_TERMEXEC_TEST_OK'")
            until(
                lambda: "NVIM_TERMEXEC_TEST_OK"
                in " ".join(n.buffers[term["bufnr"]][:]),
                "TermExec command output",
            )
            n.command("stopinsert")
            if lua("return require('toggleterm.terminal').get(1):is_open()"):
                n.command("ToggleTerm")
            checks["termexec"] = True
            n.command("DiffviewOpen")
            until(
                lambda: lua("return require('diffview.lib').get_current_view() ~= nil"),
                "Diffview view",
            )
            until(
                lambda: lua(
                    "for _,w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype=='DiffviewFiles' then return true end end"
                ),
                "Diffview file panel",
            )
            checks["diffview_open"] = True
            n.command("DiffviewClose")
            until(
                lambda: lua("return require('diffview.lib').get_current_view() == nil"),
                "Diffview close",
            )
            n.command("DiffviewFileHistory %")
            until(
                lambda: lua("return require('diffview.lib').get_current_view() ~= nil"),
                "Diffview history",
            )
            until(
                lambda: lua(
                    "for _,w in ipairs(vim.api.nvim_list_wins()) do local b=vim.api.nvim_win_get_buf(w); if vim.bo[b].filetype=='DiffviewFileHistory' then return true end end"
                ),
                "history panel",
            )
            until(
                lambda: lua("""
                    for _,w in ipairs(vim.api.nvim_list_wins()) do
                        local b=vim.api.nvim_win_get_buf(w)
                        if vim.bo[b].filetype=="DiffviewFileHistory"
                            and table.concat(vim.api.nvim_buf_get_lines(b,0,-1,false)," "):find("Fixture commit",1,true)
                        then return true end
                    end
                """),
                "actual commit history content",
            )
            checks["diffview_history"] = True
            n.command("DiffviewClose")
            n.command("checkhealth vim.deprecated")
            checks["health"] = "\n".join(n.current.buffer[:])
            checks["messages"] = n.command_output("messages")
            warnings = [s for s in checks["health"].splitlines() if "WARNING" in s]
            print(
                json.dumps(
                    {
                        "completed": list(checks),
                        "warnings": warnings,
                        "messages": checks["messages"],
                    },
                    ensure_ascii=False,
                )
            )
            assert (
                not warnings
            ), "Deprecated API triggered; inspect DEFERRED_TEST_REPORT"
            assert "Error executing" not in checks["messages"], checks["messages"]
        finally:
            report = os.environ.get("DEFERRED_TEST_REPORT")
            if report:
                Path(report).write_text(
                    json.dumps(checks, ensure_ascii=False, indent=2)
                )
            try:
                n.command("qa!")
            except (EOFError, OSError):
                pass
            for key, value in saved.items():
                if value is None:
                    os.environ.pop(key, None)
                else:
                    os.environ[key] = value


if __name__ == "__main__":
    run()
