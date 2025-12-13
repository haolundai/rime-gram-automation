#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# 乾淨重建 venv
rm -rf .venv
python3 -m venv .venv

# 啟用 venv（讓後面 python/pip 都在乾淨環境裡跑）
source .venv/bin/activate

bash ./scripts/bootstrap_wsl.sh

bash ./run.sh

echo "Clean verify OK"
