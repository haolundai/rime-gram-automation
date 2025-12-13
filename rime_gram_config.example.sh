# === 1) 你的語料（Windows 路徑映射到 WSL /mnt/…）===
# Windows: E:\Desktop\Rime backup\LLM Training\corpus\corpus_all.txt
export CORPUS_WIN_MNT="/mnt/<drive>/path/to/corpus_all.txt"

# === 2) 你的 artifact tarball（Windows 端那個 rime--Linux-gcc.tar.bz2）===
# 例：Windows: D:\Downloads\rime--Linux-gcc.tar.bz2
export RIME_TARBALL_WIN_MNT="/mnt/<drive>/path/to/rime--Linux-gcc.tar.bz2"

# === 3) 你的 Windows 使用者名稱（用於寫入 %APPDATA%\Rime）===
# 對應：C:\Users\<WINUSER>\AppData\Roaming\Rime
export WINUSER="<WINUSER>"

# === 4) (可選) 你要用的 rime-build-grammar repo 來源（可換成你的 fork）===
export RIME_BUILD_GRAMMAR_REPO="https://github.com/haolundai/rime-build-grammar.git"

# === 5) (可選) KenLM 訓練參數 ===
export LM_ORDER=8
export KENLM_MAX_ORDER=10
export KENLM_MEM="80%"

# 如果你想「不怕大、先保留多一點」，可以先把 prune 關掉：
# export KENLM_PRUNE=""
# 如果你想先維持你之前那個剪枝（較保守），就用這行：
export KENLM_PRUNE="0 0 2 2 2 2 2 2"

# === 6) (可選) merge 檔選擇（固定用 3~7）===
export MERGE_FILE_EXACT="merge_3_4_5_6_7.txt"

# === 7) (可選) merge 分階門檻（merge_ngram.py 會讀這個）===
# 注意：你目前的 ngram_6/7_frequencies.txt 裡 freq 最小就 >=10，所以 2/10 這種門檻不會有差異；
# 先留著當「未來改 arpa.py / 頻率尺度」時用的旋鈕。
export MERGE_MIN_FREQ_BY_N="3:2,4:2,5:2,6:2,7:2"
