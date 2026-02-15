@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%" >nul

if not exist ".venv\Scripts\python.exe" (
  echo ERROR: .venv not found in project root.
  echo Run jupyter_install.bat first.
  popd >nul
  exit /b 1
)

".venv\Scripts\python.exe" -m jupyter lab %*
set "EXIT_CODE=%ERRORLEVEL%"

popd >nul
exit /b %EXIT_CODE%
