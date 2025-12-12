# === 1) 你的語料（Windows 路徑映射到 WSL /mnt/…）===
# Windows: E:\Desktop\Rime backup\LLM Training\corpus\corpus_all.txt
export CORPUS_WIN_MNT="/mnt/e/Desktop/Rime backup/LLM Training/corpus/corpus_all.txt"

# === 2) 你的 artifact tarball（Windows 端那個 rime--Linux-gcc.tar.bz2）===
# 例：Windows: D:\Downloads\rime--Linux-gcc.tar.bz2
export RIME_TARBALL_WIN_MNT="/mnt/e/Desktop/Rime backup/LLM Training/rime--Linux-gcc.tar.bz2"

# === 3) 你的 Windows 使用者名稱（用於寫入 %APPDATA%\Rime）===
# 對應：C:\Users\<WINUSER>\AppData\Roaming\Rime
export WINUSER="haolundaiPC"

# === 4) (可選) 你要用的 rime-build-grammar repo 來源（可換成你的 fork）===
export RIME_BUILD_GRAMMAR_REPO="https://github.com/haolundai/rime-build-grammar.git"
