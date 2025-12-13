#!/usr/bin/env bash
set -euo pipefail

# 不管你從哪個目錄呼叫，都切回 repo 根目錄再做事
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# 乾淨重建 venv（每次都從零開始）
rm -rf .venv
python3 -m venv .venv

# 啟用 venv（讓後面 python/pip 都在乾淨環境裡跑）
# shellcheck disable=SC1091
source .venv/bin/activate

# 用你 README 提到的 bootstrap（你指定要跑這支）
bash ./scripts/bootstrap_wsl.sh

# 跑流程：不需要 chmod，直接用 bash 執行即可
bash ./run.sh

echo "Clean verify OK"
