#!/usr/bin/env bash
set -euo pipefail


# ----------------------------
# 0) Load config
# ----------------------------
if [[ -f "$HOME/.rime_gram_config.sh" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.rime_gram_config.sh"
fi

: "${CORPUS_WIN_MNT:?Missing CORPUS_WIN_MNT in ~/.rime_gram_config.sh}"
: "${RIME_TARBALL_WIN_MNT:?Missing RIME_TARBALL_WIN_MNT in ~/.rime_gram_config.sh}"
: "${WINUSER:?Missing WINUSER in ~/.rime_gram_config.sh}"
: "${RIME_BUILD_GRAMMAR_REPO:=https://github.com/gaboolic/rime-build-grammar.git}"

# ----------------------------
# 1) Workspace folders
# ----------------------------
BASE="$HOME/my-gram-train"
RUNS="$BASE/runs"
ART="$HOME/artifacts"
KDIR="$HOME/kenlm"
RBG="$HOME/rime-build-grammar"

mkdir -p "$RUNS" "$ART"

RUN="$RUNS/run-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN"
echo "[INFO] RUN=$RUN"

# ----------------------------
# 2) Bring corpus into WSL (avoid working directly on /mnt/*)
# ----------------------------
cp -av "$CORPUS_WIN_MNT" "$RUN/corpus_all.txt"
echo "[INFO] corpus size:"
ls -lah "$RUN/corpus_all.txt"

# ----------------------------
# 3) Python venv + jieba (avoid PEP 668 externally-managed-environment)
# ----------------------------
#sudo apt-get update -y
#sudo apt-get install -y python3-venv python3-pip

python3 -m venv "$RUN/.venv"
# shellcheck disable=SC1090
source "$RUN/.venv/bin/activate"
python3 -m pip install -U pip
pip install jieba

cat > "$RUN/seg.py" <<'PY'
import jieba

in_path = "corpus_all.txt"
out_path = "corpus_seg.txt"

with open(in_path, "r", encoding="utf-8", errors="ignore") as fin, \
     open(out_path, "w", encoding="utf-8") as fout:
    for line in fin:
        line = line.strip()
        if not line:
            continue
        words = jieba.cut(line, cut_all=False)
        fout.write(" ".join(words) + "\n")
PY

pushd "$RUN" >/dev/null
python3 ./seg.py
ls -lah ./corpus_seg.txt
popd >/dev/null

# ----------------------------
# 4) Ensure KenLM (build lmplz if missing)
# ----------------------------
#sudo apt-get install -y git build-essential cmake \
  #libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-test-dev \
  #libeigen3-dev zlib1g-dev libbz2-dev liblzma-dev

for cmd in git cmake make; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "[ERR] missing $cmd; run one-time setup in WSL"; exit 20; }
done


if [[ ! -x "$KDIR/build/bin/lmplz" ]]; then
  echo "[INFO] Building KenLM (lmplz)..."
  if [[ ! -d "$KDIR/.git" ]]; then
    git clone https://github.com/kpu/kenlm "$KDIR"
  fi
  mkdir -p "$KDIR/build"
  pushd "$KDIR/build" >/dev/null
  cmake ..
  make -j"$(nproc)"
  popd >/dev/null
fi

LMPLZ="$KDIR/build/bin/lmplz"
echo "[INFO] LMPLZ=$LMPLZ"
ls -lah "$LMPLZ"

# ----------------------------
# 5) KenLM train: corpus_seg.txt -> my_model.arpa
# ----------------------------
"$LMPLZ" -o 6 < "$RUN/corpus_seg.txt" > "$RUN/my_model.arpa"
ls -lah "$RUN/my_model.arpa"
tail -n 3 "$RUN/my_model.arpa" || true

# ----------------------------
# 6) Ensure rime-build-grammar repo
# ----------------------------
if [[ ! -d "$RBG/.git" ]]; then
  git clone "$RIME_BUILD_GRAMMAR_REPO" "$RBG"
fi

# ----------------------------
# 7) Prepare artifact: extract tarball & locate build_grammar
# ----------------------------
cp -av "$RIME_TARBALL_WIN_MNT" "$ART/rime--Linux-gcc.tar.bz2"
cd "$ART"
if [[ ! -d "$ART/rime-linux-gcc-extracted" ]]; then
  mkdir -p "$ART/rime-linux-gcc-extracted"
  tar -jxvf "$ART/rime--Linux-gcc.tar.bz2" -C "$ART/rime-linux-gcc-extracted"
fi

BUILD_GRAMMAR_PATH="$(find "$ART/rime-linux-gcc-extracted" -type f -path "*/plugins/octagram/bin/build_grammar" | head -n 1)"
if [[ -z "${BUILD_GRAMMAR_PATH:-}" ]]; then
  echo "[ERR] build_grammar not found under $ART/rime-linux-gcc-extracted"
  exit 2
fi

RIME_BUILD="${BUILD_GRAMMAR_PATH%/plugins/octagram/bin/build_grammar}"
export LD_LIBRARY_PATH="$RIME_BUILD/lib:$RIME_BUILD/lib/rime-plugins:${LD_LIBRARY_PATH:-}"
echo "[INFO] RIME_BUILD=$RIME_BUILD"
echo "[INFO] BUILD_GRAMMAR_PATH=$BUILD_GRAMMAR_PATH"

# Quick dependency check
if ldd "$BUILD_GRAMMAR_PATH" | grep -q "not found"; then
  echo "[ERR] Missing shared libraries for build_grammar (ldd shows 'not found')."
  ldd "$BUILD_GRAMMAR_PATH" | sed -n '1,160p'
  exit 3
fi

# ----------------------------
# 8) arpa.py -> ngram_* ; merge_ngram.py -> merge_*.txt ; build_grammar -> zh-hant.gram
# ----------------------------
cd "$RBG"

BK="$RBG/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BK"
mv -f ngram_*_frequencies.txt merge_*.txt "$BK"/ 2>/dev/null || true
cp -av zh-hant.gram "$BK"/ 2>/dev/null || true

cp -av "$RUN/my_model.arpa" "$RBG/my_model.arpa"

python3 arpa.py my_model.arpa my_model.txt > "$RUN/arpa.log" 2>&1
python3 merge_ngram.py > "$RUN/merge.log" 2>&1

MERGE_FILE="$(ls -t merge_*.txt | head -n 1)"
echo "[INFO] MERGE_FILE=$MERGE_FILE"
ls -lah "$MERGE_FILE"

# Build gram (writes zh-hant.gram in this dir)
cat "$MERGE_FILE" | "$BUILD_GRAMMAR_PATH" 2> "$RUN/build_grammar.log"
ls -lah zh-hant.gram
tail -n 30 "$RUN/build_grammar.log" || true

# Save artifacts back to RUN folder
cp -av zh-hant.gram "$RUN/zh-hant.gram"

# ----------------------------
# 9) Copy back to Windows (Downloads + AppData\Roaming\Rime)
# ----------------------------
WIN_DL="/mnt/c/Users/$WINUSER/Downloads"
WIN_RIME="/mnt/c/Users/$WINUSER/AppData/Roaming/Rime"

mkdir -p "$WIN_DL"
cp -av "$RUN/zh-hant.gram" "$WIN_DL/zh-hant.gram"

if [[ -d "$WIN_RIME" ]]; then
  cp -av "$RUN/zh-hant.gram" "$WIN_RIME/zh-hant.gram"
  echo "[INFO] Copied to %APPDATA%\\Rime\\zh-hant.gram"
else
  echo "[WARN] Rime user folder not found: $WIN_RIME"
fi

echo "[DONE] New gram at:"
echo "  $WIN_DL/zh-hant.gram"
echo "  $WIN_RIME/zh-hant.gram (if folder exists)"
echo "[NEXT] Re-deploy in Weasel (小狼毫) to take effect."
