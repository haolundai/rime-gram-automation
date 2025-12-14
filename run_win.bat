@echo off
setlocal
set LOG=%~dp0UpdateRimeGram.log

echo ===== %DATE% %TIME% ===== > "%LOG%"
echo Running... please wait (see %LOG%)

wsl.exe -e bash -lc "~/my-gram-train/train_gram.sh" >> "%LOG%" 2>&1

echo ExitCode=%ERRORLEVEL%>> "%LOG%"
echo Done. ExitCode=%ERRORLEVEL%
pause
endlocal
