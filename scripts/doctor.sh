#!/usr/bin/env bash
set -eEuo pipefail

trap 'echo "[ERR] line=$LINENO cmd=$BASH_COMMAND" >&2' ERR

die() { echo "[ERR] $*" >&2; exit 1; }
info(){ echo "[INFO] $*"; }
ok()  { echo "[OK] $*"; }

CONFIG="${HOME}/.rime_gram_config.sh"
[[ -f "$CONFIG" ]] || die "Missing config: $CONFIG (copy from rime_gram_config.example.sh and edit)."
# shellcheck disable=SC1090
source "$CONFIG"

: "${CORPUS_WIN_MNT:?Missing CORPUS_WIN_MNT in config}"
: "${RIME_TARBALL_WIN_MNT:?Missing RIME_TARBALL_WIN_MNT in config}"

[[ -f "$CORPUS_WIN_MNT" ]] || die "Corpus not found: $CORPUS_WIN_MNT"
[[ -f "$RIME_TARBALL_WIN_MNT" ]] || die "Tarball not found: $RIME_TARBALL_WIN_MNT"

for c in bash git python3 cmake make tar ldd; do
  command -v "$c" >/dev/null 2>&1 || die "Missing command: $c"
done

ART="${HOME}/artifacts"
if [[ -d "$ART" ]]; then
  BUILD_GRAMMAR_PATH="$(find "$ART" -type f -path "*/plugins/octagram/bin/build_grammar" 2>/dev/null | head -n 1 || true)"
  if [[ -n "${BUILD_GRAMMAR_PATH:-}" && -f "$BUILD_GRAMMAR_PATH" ]]; then
    info "Checking shared libs: $BUILD_GRAMMAR_PATH"
    missing="$(ldd "$BUILD_GRAMMAR_PATH" | awk '/not found/{print $1}' || true)"
    if [[ -n "$missing" ]]; then
      echo "[ERR] Missing shared libraries:" >&2
      echo "$missing" | sed 's/^/  - /' >&2

      if command -v apt-file >/dev/null 2>&1; then
        echo "[INFO] Suggested packages (best-effort via apt-file):" >&2
        while IFS= read -r so; do
          [[ -z "$so" ]] && continue
          apt-file search -x "/${so}$" 2>/dev/null | head -n 5 | sed 's/^/  /' >&2 || true
        done <<< "$missing"
      else
        echo "[INFO] Install apt-file to map .so -> package: sudo apt install apt-file && sudo apt-file update" >&2
      fi
      exit 2
    else
      ok "No missing shared libraries."
    fi
  fi
fi

ok "Doctor checks passed."
