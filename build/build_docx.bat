@echo off
setlocal enabledelayedexpansion

REM buildフォルダにいる前提。mdのある親フォルダへ
pushd "%~dp0"
set "ROOT=.."

set "IN=%ROOT%\CGJ-design.md"
set "OUT=%ROOT%\CGJ-design.md"
set "REFDOC=%~dp0reference.docx"
set "LOG=%~dp0build_docx.log"

echo === Working dir ===
cd
echo === Input  === %IN%
echo === Output === %OUT%
if exist "%REFDOC%" (
  echo === Reference DOCX === %REFDOC%
) else (
  echo === Reference DOCX === (not found; pandoc default styles)
)
echo.

if not exist "%IN%" (
  echo [ERROR] Input file not found: %IN%
  goto END
)

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "TODAY=%%i"

REM pandoc実行（ログはbuildフォルダへ）
REM NOTE:
REM  - reference.docx を build フォルダに置くと、Wordのスタイル（見た目）を完全に固定できます。
REM  - 画像は --resource-path で参照します（md内の img/ などを想定）。
if exist "%REFDOC%" (
  pandoc "%IN%" -o "%OUT%" ^
    --resource-path=".;.." ^
    --reference-doc="%REFDOC%" ^
    --filter pandoc-crossref ^
    --toc ^
    --toc-depth=3 ^
    -N ^
    -M date="Updated date: %TODAY%" ^
    --citeproc ^
    --verbose > "%LOG%" 2>&1
) else (
  pandoc "%IN%" -o "%OUT%" ^
    --resource-path=".;.." ^
    --filter pandoc-crossref ^
    --toc ^
    --toc-depth=3 ^
    -N ^
    -M date="Updated date: %TODAY%" ^
    --citeproc ^
    --verbose > "%LOG%" 2>&1
)

set "EC=%ERRORLEVEL%"
echo === pandoc exit code: %EC% ===

if not "%EC%"=="0" (
  echo [ERROR] Build failed. See "%LOG%"
  goto END
)

if exist "%OUT%" (
  echo [OK] Generated: %OUT%
) else (
  echo [ERROR] pandoc reported success but output not found.
  echo See "%LOG%"
)

:END
echo.
echo (Press any key to close)
pause > nul
popd
endlocal