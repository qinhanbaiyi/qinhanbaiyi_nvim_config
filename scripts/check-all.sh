#!/usr/bin/env bash
# 完整回归只使用临时项目和本地 AI 替身，不发送用户代码。
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
bash scripts/check.sh
for test in lsp git editor ai deferred; do
  timeout -k 2 150 uv run --no-project --with pynvim==0.6.0 python "tests/$test.py"
done
