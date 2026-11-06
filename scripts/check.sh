#!/usr/bin/env bash
# 在已安装这份配置的 WSL/Linux 环境运行；也支持隔离的 XDG_* 测试目录。
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export NVIM_CONFIG_TEST_ROOT="$root"
cd "$root"
stylua --check init.lua lua tests
timeout -k 2 45 "${NVIM_BIN:-nvim}" --headless --cmd 'let g:codeium_enabled = v:false'   "+luafile $root/tests/smoke.lua" </dev/null
timeout -k 2 45 "${NVIM_BIN:-nvim}" --headless --cmd 'let g:codeium_enabled = v:false'   "+luafile $root/tests/snippets.lua" </dev/null
timeout -k 2 45 "${NVIM_BIN:-nvim}" --headless --cmd 'let g:codeium_enabled = v:false'   "+luafile $root/tests/tooling.lua" </dev/null
