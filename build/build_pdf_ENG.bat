@echo off
setlocal enabledelayedexpansion

REM buildフォルダにいる前提。mdのある親フォルダへ
pushd "%~dp0"
set "ROOT=.."

set "IN=%ROOT%\Plan-for-Bridge-Activity_ENG.md"
set "OUT=%ROOT%\Plan-for-Bridge-Activity_ENG.pdf"
set "HEADER=%~dp0header.tex"
set "LOG=%~dp0build.log"

echo === Working dir ===
cd
echo === Input  === %IN%
echo === Output === %OUT%
echo === Header === %HEADER%
echo.

if not exist "%IN%" (
  echo [ERROR] Input file not found: %IN%
  goto END
)

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "TODAY=%%i"

REM pandoc実行（ログはbuildフォルダへ）
pandoc "%IN%" -o "%OUT%" ^
  --resource-path=".;.." ^
  --pdf-engine=lualatex ^
  --include-in-header="%HEADER%" ^
  --filter pandoc-crossref ^
  --toc ^
  --toc-depth=3 ^
  -N ^
  -M date="Updated date: %TODAY%" ^
  --citeproc ^
  --verbose > "%LOG%" 2>&1

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