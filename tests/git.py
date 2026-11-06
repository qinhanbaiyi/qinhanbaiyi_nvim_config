"""在临时 Git 仓库中验证 hunk 键位、预览、blame 和缩进线。

运行 uv run --no-project --with pynvim==0.6.0 python tests/git.py。
继承 XDG_CONFIG_HOME / XDG_DATA_HOME，NVIM_BIN 可指定 Neovim。
仅修改本测试的临时仓库和缓冲区，不读取用户项目或执行远程 Git 操作。
"""

from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

import pynvim


def run() -> None:
    executable = os.environ.get("NVIM_BIN") or shutil.which("nvim")
    if not executable:
        raise RuntimeError("nvim was not found; set NVIM_BIN")
    checks: dict = {}

    with tempfile.TemporaryDirectory(prefix="nvim-git-test-") as tmp:
        root = Path(tmp)
        repo = root / "project"
        repo.mkdir()

        def git(*args: str) -> str:
            return subprocess.check_output(
                ["git", "-c", "core.hooksPath=/dev/null", "-C", str(repo), *args],
                text=True,
            )

        initial = [f"local value_{i:02} = {i}" for i in range(1, 61)]
        path = repo / "example.lua"
        path.write_text("\n".join(initial) + "\n")
        git("init", "-q")
        git("add", "example.lua")
        git(
            "-c",
            "user.name=Neovim Test",
            "-c",
            "user.email=nvim-test@example.invalid",
            "commit",
            "-qm",
            "Initial fixture",
        )
        committed = initial[:]
        committed[-1] = "local value_60 = 600"
        path.write_text("\n".join(committed) + "\n")
        git("add", "example.lua")
        git(
            "-c",
            "user.name=Neovim Test",
            "-c",
            "user.email=nvim-test@example.invalid",
            "commit",
            "-qm",
            "Second fixture",
        )
        working = committed[:]
        working[4] = "local value_05 = 555"
        working[39] = "local value_40 = 444"
        del working[19]
        path.write_text("\n".join(working) + "\n")

        saved_env = {k: os.environ.get(k) for k in ("XDG_STATE_HOME", "XDG_CACHE_HOME")}
        os.environ["XDG_STATE_HOME"] = str(root / "state")
        os.environ["XDG_CACHE_HOME"] = str(root / "cache")
        nvim = pynvim.attach(
            "child",
            argv=[
                executable,
                "--embed",
                "--headless",
                "--cmd",
                "let g:codeium_enabled = v:false",
                str(path),
            ],
        )
        nvim.ui_attach(160, 50, rgb=True)

        def lua(source: str, *args):
            return nvim.exec_lua(source, *args)

        def until(fn, description: str, seconds=15):
            deadline = time.monotonic() + seconds
            while time.monotonic() < deadline:
                value = fn()
                if value:
                    return value
                time.sleep(0.1)
            raise AssertionError(f"Timed out waiting for {description}")

        def hunks():
            return lua("return require('gitsigns').get_hunks()") or []

        def close_auxiliary():
            for win in nvim.windows:
                if win.handle != main_win:
                    nvim.api.win_close(win.handle, True)
            nvim.api.set_current_win(main_win)
            nvim.command("diffoff!")
            time.sleep(0.15)

        def all_text():
            return "\n".join(
                "\n".join(
                    nvim.api.buf_get_lines(nvim.api.win_get_buf(win), 0, -1, False)
                )
                for win in nvim.api.list_wins()
                if win != main_win
            )

        try:
            main_buf = nvim.current.buffer.number
            main_win = nvim.current.window.handle
            until(lambda: lua("return vim.b.gitsigns_head ~= nil"), "Gitsigns attach")
            until(lambda: len(hunks()) == 3, "three independent hunks")
            checks["git_attach_and_hunks"] = hunks()
            assert (
                lua("return require('gitsigns.config').config.signs_staged_enable")
                is False
            )

            # 使用用户实际映射，验证普通窗口的前后 hunk 跳转。
            nvim.current.window.cursor = (1, 0)
            nvim.input("]c")
            until(lambda: nvim.current.window.cursor[0] == 5, "]c first hunk")
            nvim.input("]c")
            until(lambda: nvim.current.window.cursor[0] == 19, "]c deletion hunk")
            nvim.input("[c")
            until(lambda: nvim.current.window.cursor[0] == 5, "[c previous hunk")
            checks["hunk_navigation_keys"] = True

            nvim.input(" hs")
            until(lambda: "value_05 = 555" in git("show", ":example.lua"), "stage hunk")
            assert "value_40 = 444" not in git("show", ":example.lua")
            checks["stage_hunk"] = True
            nvim.current.window.cursor = (39, 0)
            nvim.input(" hu")
            until(lambda: git("diff", "--cached") == "", "undo last stage")
            checks["undo_last_stage_away_from_cursor"] = True
            until(lambda: len(hunks()) == 3, "refresh after undo stage")

            nvim.current.window.cursor = (5, 0)
            nvim.input(" hr")
            until(lambda: nvim.current.buffer[4] == committed[4], "reset hunk")
            assert "local value_40 = 444" in nvim.current.buffer[:]
            checks["reset_hunk"] = True
            nvim.input(" hR")
            until(lambda: nvim.current.buffer[:] == committed, "reset full buffer")
            until(lambda: not hunks(), "reset signs")
            checks["reset_buffer"] = True

            nvim.current.buffer[:] = working
            until(lambda: len(hunks()) == 3, "edited buffer hunks")
            nvim.input(" hS")
            until(
                lambda: git("show", ":example.lua").splitlines() == working,
                "stage buffer",
            )
            checks["stage_buffer"] = True
            # get_hunks() 在重算期间也可能返回空表，不能当作异步操作完成信号。
            # 先等待去抖 watcher 看到“已暂存 blob”，再执行独立的外部 reset；
            # 否则两个索引事件可能合并，测试在前一次变更尚未被观察时就撤销了它。
            staged_blob = git("rev-parse", ":example.lua").strip()
            until(
                lambda: lua(
                    """
                    local expected = ...
                    local c = require("gitsigns.cache").cache[vim.api.nvim_get_current_buf()]
                    return c and c.git_obj.object_name == expected
                        and c.hunks ~= nil and #c.hunks == 0
                """,
                    staged_blob,
                ),
                "watcher observes staged index blob and completed zero-hunk diff",
            )
            git("reset", "-q", "HEAD", "--", "example.lua")
            reset_blob = git("rev-parse", ":example.lua").strip()
            assert reset_blob != staged_blob
            # 不主动 refresh，必须由真实文件监控重新识别索引并恢复全部三个 hunk。
            until(
                lambda: lua(
                    """
                    local expected = ...
                    local c = require("gitsigns.cache").cache[vim.api.nvim_get_current_buf()]
                    return c and c.git_obj.object_name == expected
                """,
                    reset_blob,
                )
                and len(hunks()) == 3,
                "index watcher after reset",
            )
            checks["index_watcher_stage_and_external_reset"] = True

            nvim.current.window.cursor = (5, 0)
            nvim.input(" hp")
            until(lambda: "555" in all_text() and "= 5" in all_text(), "hunk preview")
            checks["hunk_preview"] = True
            close_auxiliary()
            nvim.current.window.cursor = (1, 0)
            nvim.input(" hb")
            until(lambda: "Neovim Test" in all_text(), "full blame popup")
            checks["full_blame"] = True
            close_auxiliary()
            nvim.input(" tb")
            until(
                lambda: lua(
                    "return require('gitsigns.config').config.current_line_blame"
                ),
                "line blame enabled",
            )
            until(
                lambda: lua("return vim.b.gitsigns_blame_line_dict ~= nil"),
                "line blame result",
            )
            nvim.input(" tb")
            until(
                lambda: not lua(
                    "return require('gitsigns.config').config.current_line_blame"
                ),
                "line blame disabled",
            )
            checks["line_blame_toggle"] = True

            # hd/hD 分别读取索引/上一提交；对比缓冲区的文本必须与 git show 一致。
            for keys, base, expected in [
                (" hd", "index", committed),
                (" hD", "previous_commit", initial),
            ]:
                nvim.input(keys)
                until(lambda: len(nvim.windows) > 1, f"{base} diff split")
                until(
                    lambda: any(
                        nvim.api.buf_get_lines(nvim.api.win_get_buf(w), 0, -1, False)
                        == expected
                        for w in nvim.api.list_wins()
                        if w != main_win
                    ),
                    f"{base} diff contents",
                )
                nvim.api.set_current_win(main_win)
                assert lua("return vim.wo.diff") is True
                assert (
                    lua("return vim.fn.maparg(']c','n',false,true).callback()") == "]c"
                )
                assert (
                    lua("return vim.fn.maparg('[c','n',false,true).callback()") == "[c"
                )
                checks[f"diff_{base}_and_native_navigation"] = True
                close_auxiliary()

            nvim.input(" td")
            until(
                lambda: lua("return require('gitsigns.unified').get_view() ~= nil"),
                "unified deleted-line view",
            )
            # 不只检查开关状态，确认真实删除行作为虚拟行显示。
            virtual_lines = until(
                lambda: lua("""
                local ns=vim.api.nvim_create_namespace("gitsigns_unified_" .. vim.api.nvim_get_current_win())
                local out={}
                for _,m in ipairs(vim.api.nvim_buf_get_extmarks(0,ns,0,-1,{details=true})) do
                    for _,line in ipairs(m[4].virt_lines or {}) do
                        for _,chunk in ipairs(line) do out[#out+1]=chunk[1] end
                    end
                end
                local text=table.concat(out,"\\n")
                return text:find("value_20",1,true) and text or nil
            """),
                "deleted line in unified virtual lines",
            )
            checks["deleted_line_toggle"] = virtual_lines
            nvim.input(" td")
            until(
                lambda: lua("return require('gitsigns.unified').get_view() == nil"),
                "unified view closed",
            )

            # 在临时 Lua 缓冲区验证真实缩进 extmark，开关后行尾箭头仍保持原样。
            nvim.current.buffer[:] = [
                "local function nested()",
                "  if true then",
                "    print('indent')",
                "  end",
                "end",
            ]
            nvim.current.window.cursor = (3, 5)
            original_listchars = nvim.options["listchars"]
            until(
                lambda: lua("""
                require("ibl").refresh(0)
                return #vim.api.nvim_buf_get_extmarks(0,
                    vim.api.nvim_create_namespace("indent_blankline"),0,-1,{}) > 0
            """),
                "IBL indentation marks",
            )
            nvim.input(" ug")
            until(
                lambda: not lua("return require('ibl.config').get_config(0).enabled"),
                "IBL disabled",
            )
            assert (
                lua(
                    "return #vim.api.nvim_buf_get_extmarks(0,vim.api.nvim_create_namespace('indent_blankline'),0,-1,{})"
                )
                == 0
            )
            nvim.input(" ug")
            until(
                lambda: lua("return require('ibl.config').get_config(0).enabled"),
                "IBL enabled",
            )
            until(
                lambda: lua("""
                require("ibl").refresh(0)
                return #vim.api.nvim_buf_get_extmarks(0,
                    vim.api.nvim_create_namespace("indent_blankline"),0,-1,{}) > 0
            """),
                "IBL marks restored",
            )
            assert nvim.options["listchars"] == original_listchars
            checks["ibl_toggle_and_marks"] = True

            nvim.command("checkhealth vim.deprecated")
            health = "\n".join(nvim.current.buffer[:])
            checks["deprecated_health"] = health
            assert "/gitsigns.nvim/" not in health, health
            assert "/indent-blankline.nvim/" not in health, health
            messages = nvim.command_output("messages")
            checks["messages"] = messages
            assert "Error executing" not in messages, messages
            assert "deprecated" not in messages, messages
            print(json.dumps({"passed": list(checks)}, ensure_ascii=False))
        except Exception:
            print(
                json.dumps(
                    {
                        "completed": list(checks),
                        "messages": nvim.command_output("messages"),
                        "current_buffer": nvim.current.buffer[:],
                    },
                    ensure_ascii=False,
                )
            )
            raise
        finally:
            report = os.environ.get("GIT_TEST_REPORT")
            if report:
                Path(report).write_text(
                    json.dumps(checks, ensure_ascii=False, indent=2)
                )
            try:
                nvim.command("qa!")
            except (EOFError, OSError):
                pass
            for key, value in saved_env.items():
                if value is None:
                    os.environ.pop(key, None)
                else:
                    os.environ[key] = value


if __name__ == "__main__":
    run()
