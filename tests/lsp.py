"""通过 Neovim RPC UI 验证真实 LuaLS、Saga、Outline 和 Blink。

先安装锁定的插件和 Mason 中的 lua-language-server，再运行
    uv run --no-project --with pynvim==0.6.0 python tests/lsp.py

NVIM_BIN 可指定 Neovim 可执行文件。继承 XDG_CONFIG_HOME / XDG_DATA_HOME，
以选择待测配置；编辑内容、状态、日志和缓存均使用临时目录。
LSP_TEST_REPORT 可保存完整 JSON 报告，测试不打开或保存用户文件。
"""

from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import tempfile
import time
import traceback

import pynvim


def run() -> None:
    executable = os.environ.get("NVIM_BIN") or shutil.which("nvim")
    if not executable:
        raise RuntimeError("nvim was not found; set NVIM_BIN to its executable path")
    fixture_source = Path(__file__).resolve().parent / "fixtures" / "lsp"
    checks: dict = {}
    report_path = os.environ.get("LSP_TEST_REPORT")

    with tempfile.TemporaryDirectory(prefix="nvim-lsp-test-") as temp_dir:
        temp = Path(temp_dir)
        fixture = temp / "project"
        shutil.copytree(fixture_source, fixture)
        env_before = {
            key: os.environ.get(key) for key in ("XDG_STATE_HOME", "XDG_CACHE_HOME")
        }
        os.environ["XDG_STATE_HOME"] = str(temp / "state")
        os.environ["XDG_CACHE_HOME"] = str(temp / "cache")
        nvim = pynvim.attach(
            "child",
            argv=[
                executable,
                "--embed",
                "--headless",
                "--cmd",
                "let g:codeium_enabled = v:false",
                str(fixture / "main.lua"),
            ],
        )
        nvim.ui_attach(160, 50, rgb=True)

        def lua(source: str, *args):
            return nvim.exec_lua(source, *args)

        # 轮询真实异步结果，避免把加载提示或动画窗口误认成功。
        def until(fn, label: str, seconds: float = 15):
            deadline = time.monotonic() + seconds
            while time.monotonic() < deadline:
                result = fn()
                if result:
                    return result
                time.sleep(0.1)
            raise AssertionError(f"Timed out waiting for {label}")

        def windows():
            return lua("""
                local result = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    result[#result + 1] = {
                        win = win, buf = buf, ft = vim.bo[buf].filetype,
                        lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false),
                        cfg = vim.api.nvim_win_get_config(win),
                    }
                end
                return result
            """)

        # 仅清理本测试创建的编辑器窗口，始终回到临时项目的主窗口。
        def close_auxiliary():
            nvim.input("<Esc>")
            time.sleep(0.1)
            lua(
                """
                local main = ...
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if win ~= main then pcall(vim.api.nvim_win_close, win, true) end
                end
                vim.api.nvim_set_current_win(main)
            """,
                main_window,
            )
            time.sleep(0.15)

        def popup(command: str, name: str, text: str, filetype: str | None = None):
            nvim.command(command)
            until(
                lambda: any(
                    win["win"] != main_window
                    and (filetype is None or win["ft"] == filetype)
                    and any(text in line for line in win["lines"])
                    for win in windows()
                ),
                name,
            )
            checks[name] = windows()

        try:
            until(
                lambda: lua("return #vim.lsp.get_clients({bufnr=0,name='lua_ls'})==1"),
                "LuaLS attachment",
                seconds=30,
            )
            main_buffer = nvim.current.buffer.number
            main_window = nvim.current.window.handle
            original_lines = nvim.current.buffer[:]
            checks["lua_ls_attached"] = True

            libraries = until(
                lambda: lua("""
                    local w = require("lazydev.workspace").find({
                        path = vim.api.nvim_buf_get_name(0),
                    })
                    return w and w.settings.Lua and w.settings.Lua.workspace.library
                """),
                "lazydev workspace libraries",
                seconds=30,
            )
            runtime = lua("return vim.env.VIMRUNTIME")
            snacks = lua(
                "return require('lazy.core.config').plugins['snacks.nvim'].dir"
            )
            assert any(Path(p).is_relative_to(runtime) for p in libraries), libraries
            assert any(Path(p).is_relative_to(snacks) for p in libraries), libraries
            checks["lazydev_luals_runtime_and_required_plugin"] = libraries

            nvim.current.window.cursor = (10, 16)
            checks["luals_hover"] = until(
                lambda: lua("""
                    local c = vim.lsp.get_clients({bufnr=0,name="lua_ls"})[1]
                    local r = c:request_sync("textDocument/hover",
                        vim.lsp.util.make_position_params(0,c.offset_encoding),2000,0)
                    return r and r.result and vim.inspect(r.result):find("Add two values",1,true) and r.result
                """),
                "LuaLS indexing and hover",
                seconds=30,
            )
            popup("Lspsaga hover_doc", "saga_hover", "Add two values", "markdown")
            close_auxiliary()
            nvim.current.window.cursor = (10, 16)
            popup(
                "Lspsaga peek_definition",
                "saga_peek_definition",
                "function M.add",
                "lua",
            )
            nvim.input("<C-c>k")
            until(lambda: len(windows()) == 1, "original Saga preview close key")
            checks["saga_old_preview_close_key"] = True
            nvim.current.window.cursor = (7, 12)
            popup("Lspsaga finder ref", "saga_finder", "main.lua", "sagafinder")
            close_auxiliary()
            nvim.current.window.cursor = (1, 0)
            popup("Lspsaga outline", "saga_outline", "M.add", "sagaoutline")
            close_auxiliary()
            until(lambda: lua("return #vim.diagnostic.get(0)>0"), "LuaLS diagnostics")
            popup(
                "Lspsaga diagnostic_jump_next", "saga_diagnostic", "Unused", "markdown"
            )
            close_auxiliary()
            nvim.current.window.cursor = (12, 8)
            popup(
                "Lspsaga code_action",
                "saga_code_action",
                "Disable diagnostics",
                "markdown",
            )
            close_auxiliary()

            # 在 return M 前插入合法 Lua 语句，检查中文和 emoji 后的 UTF-16 位置。
            unicode_line = 'local label = "中文😀"; print(M.add(3, 4))'
            nvim.current.buffer.append(unicode_line, len(original_lines) - 1)
            nvim.current.window.cursor = (10, 16)
            popup("Lspsaga rename", "saga_rename_dialog", "add", "sagarename")
            expected_byte_column = len(
                unicode_line[: unicode_line.index("add")].encode()
            )
            until(
                lambda: lua(
                    """
                    local buf,row,col = ...
                    local ns = vim.api.nvim_create_namespace("LspsagaRename")
                    for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf,ns,0,-1,{})) do
                        if mark[2] == row and mark[3] == col then return true end
                    end
                    return false
                """,
                    main_buffer,
                    len(original_lines) - 1,
                    expected_byte_column,
                ),
                "UTF-16 rename reference highlight",
            )
            checks["saga_unicode_reference_highlight"] = True
            nvim.input("<Esc>")
            time.sleep(0.1)
            nvim.current.buffer[:] = ["sum"]
            nvim.input("<CR>")
            until(
                lambda: "function M.sum(first, second)" in nvim.buffers[main_buffer][:]
                and "local total = M.sum(1, 2)" in nvim.buffers[main_buffer][:],
                "actual Saga rename edits",
            )
            assert any(
                "print(M.sum(3, 4))" in line for line in nvim.buffers[main_buffer][:]
            )
            checks["saga_rename_edits"] = True
            close_auxiliary()
            nvim.buffers[main_buffer][:] = original_lines

            # 定向延迟 references 回调，检验取消和连续重命名不会留下过期高亮。
            lua("""
                local client = vim.lsp.get_clients({bufnr=0,name="lua_ls"})[1]
                _G.delayed_refs = { client=client, original=client.request, callbacks={} }
                client.request = function(self, method, params, callback, bufnr)
                    if method == "textDocument/references" then
                        table.insert(delayed_refs.callbacks, callback)
                        return true, 999999
                    end
                    return delayed_refs.original(self,method,params,callback,bufnr)
                end
            """)

            def delayed_prompt():
                nvim.current.window.cursor = (10, 16)
                nvim.command("Lspsaga rename")
                until(
                    lambda: nvim.current.buffer.options["filetype"] == "sagarename",
                    "delayed rename prompt",
                )
                return lua("return #delayed_refs.callbacks")

            def deliver_reference(index):
                lua(
                    """
                    local index,buf = ...
                    delayed_refs.callbacks[index](nil, {{
                        uri=vim.uri_from_bufnr(buf),
                        range={start={line=6,character=11},["end"]={line=6,character=14}},
                    }})
                """,
                    index,
                    main_buffer,
                )

            def reference_marks():
                return lua(
                    """
                    local buf=...
                    return vim.api.nvim_buf_get_extmarks(buf,
                        vim.api.nvim_create_namespace("LspsagaRename"),0,-1,{})
                """,
                    main_buffer,
                )

            def cancel_prompt():
                nvim.input("<Esc><C-k>")
                until(lambda: len(windows()) == 1, "Saga cancel key")
                assert not reference_marks(), "Cancel should clear rename highlights"

            try:
                normal = delayed_prompt()
                deliver_reference(normal)
                assert (
                    reference_marks()
                ), "Current session should display reference highlights"
                cancel_prompt()

                cancelled = delayed_prompt()
                cancel_prompt()
                deliver_reference(cancelled)
                assert (
                    not reference_marks()
                ), "Cancelled request restored stale highlights"

                older = delayed_prompt()
                cancel_prompt()
                newer = delayed_prompt()
                deliver_reference(older)
                assert (
                    not reference_marks()
                ), "Old request affected a new rename session"
                deliver_reference(newer)
                assert reference_marks(), "Latest rename request was ignored"
                cancel_prompt()

                changed = delayed_prompt()
                nvim.buffers[main_buffer][0] = original_lines[0] + " "
                deliver_reference(changed)
                assert (
                    not reference_marks()
                ), "Edited document accepted outdated positions"
                cancel_prompt()
                nvim.buffers[main_buffer][:] = original_lines
                checks["saga_reference_request_lifecycle"] = [
                    "current",
                    "cancelled",
                    "superseded",
                    "changed_document",
                ]
            finally:
                lua(
                    "delayed_refs.client.request=delayed_refs.original; delayed_refs=nil"
                )

            # LuaLS 不提供类型层级；局部替身验证请求编码和多结果选择，不冒充服务器集成测试。
            nvim.current.buffer.append(unicode_line, len(original_lines) - 1)
            nvim.current.window.cursor = (len(original_lines), expected_byte_column)
            expected_utf16_column = (
                len(unicode_line[: unicode_line.index("add")].encode("utf-16-le")) // 2
            )
            lua(
                """
                local expected_buf,expected_character = ...
                local util=require("lspsaga.util")
                local hierarchy=require("lspsaga.typehierarchy")
                local original_get,original_render,original_input =
                    util.get_client_by_method,hierarchy.type_hierarchy,vim.fn.inputlist
                local rendered=false
                local client={name="test_utf16",offset_encoding="utf-16"}
                local expected_item={name="ChosenType"}
                function client:request(method,params,callback,bufnr)
                    assert(method=="textDocument/prepareTypeHierarchy")
                    assert(bufnr==expected_buf)
                    assert(params.position.character==expected_character,"Wrong UTF-16 position")
                    callback(nil,{{name="FirstType"},expected_item})
                    return true,1
                end
                util.get_client_by_method=function() return {client} end
                vim.fn.inputlist=function() return 2 end
                hierarchy.type_hierarchy=function(_,item,selected_client)
                    assert(item==expected_item and selected_client==client)
                    rendered=true
                end
                local ok,err=xpcall(function()
                    local patched=hierarchy.send_prepare_type
                    hierarchy:send_prepare_type()
                    assert(rendered,"First hierarchy request did not render")
                    -- 模拟关闭窗口，确认第二次进入仍使用修复后的方法。
                    hierarchy.list={value={}} -- 替身渲染器没有创建真实窗口节点。
                    hierarchy:clean()
                    assert(hierarchy.send_prepare_type==patched,"Hierarchy cleanup removed compatibility fix")
                    rendered=false
                    hierarchy.type_hierarchy=function(_,item,selected_client)
                        assert(item==expected_item and selected_client==client)
                        rendered=true
                    end
                    hierarchy:send_prepare_type()
                end,debug.traceback)
                util.get_client_by_method=original_get
                hierarchy.type_hierarchy=original_render
                vim.fn.inputlist=original_input
                assert(ok,err)
                assert(rendered,"Type hierarchy did not receive the selected item")
            """,
                main_buffer,
                expected_utf16_column,
            )
            nvim.buffers[main_buffer][:] = original_lines
            checks["saga_typehierarchy_request_encoding_and_selection"] = True

            nvim.command("SymbolsOutline")
            until(
                lambda: lua("return require('outline').is_open()"),
                "legacy outline command",
            )
            until(
                lambda: any(
                    any("add" in line for line in win["lines"])
                    for win in windows()
                    if win["ft"] == "Outline"
                ),
                "Outline symbols",
            )
            checks["legacy_outline_command"] = windows()
            for row, line in enumerate(nvim.current.buffer[:], 1):
                if "add" in line:
                    nvim.current.window.cursor = (row, 0)
                    break
            count = len(windows())
            nvim.input("<C-Space>")
            until(lambda: len(windows()) > count, "Outline hover key")
            checks["outline_hover"] = windows()
            nvim.command("SymbolsOutlineClose")
            close_auxiliary()

            nvim.current.window.cursor = (10, 0)
            nvim.input("oM.add(")
            until(
                lambda: lua("""
                    return _LSP_SIG_CFG and _LSP_SIG_CFG.winnr
                        and vim.api.nvim_win_is_valid(_LSP_SIG_CFG.winnr)
                """),
                "automatic signature popup",
            )
            checks["automatic_signature"] = windows()
            close_auxiliary()
            nvim.current.window.cursor = (10, 0)
            nvim.input('olocal s = require("snac')
            until(
                lambda: lua("""
                    for _, item in ipairs(require("blink.cmp").get_items()) do
                        if item.source_id == "lazydev" and item.label == "snacks" then return true end
                    end
                    return false
                """),
                "Blink LazyDev completion item",
            )
            checks["blink_lazydev_real_menu"] = True
            nvim.input("<Esc>")
            time.sleep(0.2)

            nvim.command("checkhealth vim.deprecated")
            health = "\n".join(nvim.current.buffer[:])
            checks["deprecated_health"] = health
            warnings = [line for line in health.splitlines() if "WARNING" in line]
            # 现在要求整个弃用检查为零警告，避免插件更新悄悄带回旧接口。
            assert not warnings and "ERROR" not in health, health
            messages = nvim.command_output("messages")
            checks["messages"] = messages
            assert "position_encoding param is required" not in messages, messages
            assert "Error executing" not in messages, messages
            assert (fixture / "main.lua").read_text().splitlines() == original_lines
            print(
                json.dumps(
                    {"passed": list(checks), "remaining_health_warnings": warnings},
                    ensure_ascii=False,
                )
            )
        except Exception:
            checks["failure"] = traceback.format_exc()
            checks["last_windows"] = windows()
            checks["messages"] = nvim.command_output("messages")
            print(
                json.dumps(
                    {"completed": list(checks), "messages": checks["messages"]},
                    ensure_ascii=False,
                )
            )
            raise
        finally:
            if report_path:
                Path(report_path).write_text(
                    json.dumps(checks, ensure_ascii=False, indent=2), encoding="utf-8"
                )
            try:
                nvim.command("qa!")
            except (EOFError, OSError):
                pass
            for key, value in env_before.items():
                if value is None:
                    os.environ.pop(key, None)
                else:
                    os.environ[key] = value


if __name__ == "__main__":
    run()
