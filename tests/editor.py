"""用真实按键检查编辑习惯与 Glow 原生预览，只操作临时缓冲区和自有测试文件。"""

import json
import os
from pathlib import Path
import shutil
import tempfile
import time

import pynvim


def run():
    with tempfile.TemporaryDirectory(prefix="nvim-editor-") as folder:
        root = Path(folder)
        os.environ["XDG_STATE_HOME"] = str(root / "state")
        os.environ["XDG_CACHE_HOME"] = str(root / "cache")
        n = pynvim.attach(
            "child",
            argv=[
                os.environ.get("NVIM_BIN") or shutil.which("nvim"),
                "--embed",
                "--headless",
                "--cmd",
                "let g:codeium_enabled = v:false",
            ],
        )
        n.ui_attach(140, 45, rgb=True)
        checks = []

        def wait(predicate, label):
            deadline = time.monotonic() + 8
            while time.monotonic() < deadline:
                if predicate():
                    return
                time.sleep(0.05)
            raise AssertionError(
                "Timed out: " + label + " buffer=" + repr(n.current.buffer[:])
            )

        def reset(text, column=0, ft="lua"):
            n.input("<Esc>")
            time.sleep(0.05)
            n.command("enew!")
            n.current.buffer[:] = [text]
            n.current.buffer.options["filetype"] = ft
            n.current.window.cursor = (1, column)
            return n.current.buffer.number

        def type_expect(keys, expected, label):
            n.input(keys)
            wait(lambda: n.current.buffer[:] == [expected], label)
            wait(lambda: n.eval("mode()") == "n", label + " normal mode")
            checks.append(label)

        try:
            for keys, expected, label in [
                ("i(<Esc>", "()", "pairs_open"),
                ("i()<Esc>", "()", "pairs_skip_close"),
                ("i(<BS><Esc>", "", "pairs_delete"),
                ('i"<Esc>', '""', "pairs_quote"),
                (r"i\(<Esc>", r"\(", "pairs_escape"),
                ("i中(<Esc>", "中()", "pairs_multibyte"),
            ]:
                reset("")
                type_expect(keys, expected, label)

            reset("hello world")
            type_expect("gsaiw)", "(hello) world", "surround_add")
            reset("(hello) world", 2)
            type_expect("gsd)", "hello world", "surround_delete")
            reset("(hello) world", 2)
            type_expect('gsr)"', '"hello" world', "surround_replace")
            n.exec_lua(
                "original_input=vim.fn.input; vim.fn.input=function() return '40' end"
            )
            try:
                n.input("gsn")
                wait(
                    lambda: n.exec_lua("return MiniSurround.config.n_lines") == 40,
                    "surround_search_range",
                )
            finally:
                n.exec_lua("vim.fn.input=original_input; original_input=nil")
            checks.append("surround_search_range")

            reset("local answer = 42")
            type_expect("gcc", "-- local answer = 42", "comment_line")
            type_expect("gcc", "local answer = 42", "comment_line_restore")
            assert not n.funcs.maparg(
                "gbc", "n"
            ), "Do not add previously absent block-comment keys"

            source = reset("# Unsaved Markdown fixture", ft="markdown")
            old_lines = n.current.buffer[:]
            n.command("Glow")
            wait(
                lambda: n.current.buffer.options["filetype"] == "glowpreview",
                "markdown_window",
            )
            wait(
                lambda: any(
                    "Unsaved Markdown fixture" in line for line in n.current.buffer[:]
                ),
                "markdown_render",
            )
            assert n.buffers[source][:] == old_lines
            checks.append("markdown_unsaved_render")
            n.input("q")
            wait(lambda: n.current.buffer.number == source, "markdown_close_q")

            path = root / "quoted ' preview.md"
            path.write_text("# File argument fixture\n", encoding="utf-8")
            n.command("Glow " + n.funcs.fnameescape(str(path)))
            wait(
                lambda: any(
                    "File argument fixture" in line for line in n.current.buffer[:]
                ),
                "markdown_path",
            )
            n.input("<Esc>")
            wait(lambda: n.current.buffer.number == source, "markdown_close_escape")
            checks.append("markdown_quoted_filename")

            # 连续打开/关闭，确保旧渲染结果不会写入下一次预览缓冲区。
            for _ in range(3):
                n.command("Glow")
                n.command("Glow!")
                wait(lambda: n.current.buffer.number == source, "markdown_cancel")
            n.command("Glow")
            wait(
                lambda: any(
                    "Unsaved Markdown fixture" in line for line in n.current.buffer[:]
                ),
                "markdown_reopen",
            )
            n.input("q")
            wait(lambda: n.current.buffer.number == source, "markdown_close_last")
            checks.append("markdown_cancel_and_reopen")

            # 直接覆盖布局接口的左右分支、返回值和参数错误，避免可选 Saga 路径漏测。
            n.exec_lua("""
                local layout=require("lspsaga.layout")
                local left,right=vim.api.nvim_create_buf(false,true),vim.api.nvim_create_buf(false,true)
                layout.left_bufnr,layout.right_bufnr=left,right
                layout.current=1
                assert(layout:setlines({"left"})==layout)
                layout.current=2
                layout:setlines({"right"})
                assert(vim.api.nvim_buf_get_lines(left,0,-1,false)[1]=="left")
                assert(vim.api.nvim_buf_get_lines(right,0,-1,false)[1]=="right")
                assert(not pcall(layout.setlines,layout,42))
                local called=false
                local lb,_,rb=layout:done(function(a,_,b) called=a==left and b==right end)
                assert(called and lb==left and rb==right)
                assert(not pcall(layout.done,layout,42))
                vim.api.nvim_buf_delete(left,{force=true})
                vim.api.nvim_buf_delete(right,{force=true})
                layout.left_bufnr,layout.right_bufnr=nil,nil
            """)
            checks.append("saga_layout_validation")

            n.command("checkhealth vim.deprecated")
            health = "\n".join(n.current.buffer[:])
            assert "WARNING" not in health and "ERROR" not in health, health
            messages = n.command_output("messages")
            assert "Error" not in messages and "deprecated" not in messages, messages
            checks.append("no_deprecated_calls")
            print(
                json.dumps({"passed": checks, "messages": messages}, ensure_ascii=False)
            )
        finally:
            try:
                n.command("qa!")
            except Exception:
                pass


if __name__ == "__main__":
    run()
