@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Bootstraps a local Jupyter environment for this repo.
rem Creates .venv, installs core scientific stack + FilterPy + Jupyter + jupyter_translate.

set "PYTHON=python"
if not "%~1"=="" set "PYTHON=%~1"

echo.
echo == kalman-book: Jupyter install ==
echo Using Python: %PYTHON%

%PYTHON% -V >nul 2>&1
if errorlevel 1 (
  echo ERROR: Python not found on PATH.
  echo        Install Python 3.10+ and rerun, or pass full python.exe path:
  echo        jupyter_install.bat "C:\Path\To\python.exe"
  exit /b 1
)

if not exist ".venv\Scripts\python.exe" (
  echo Creating virtualenv: .venv
  %PYTHON% -m venv .venv
  if errorlevel 1 (
    echo ERROR: Failed to create venv.
    exit /b 1
  )
) else (
  echo Found existing virtualenv: .venv
)

set "VPY=.venv\Scripts\python.exe"

echo.
echo Upgrading pip/setuptools/wheel...
%VPY% -m pip install -U pip setuptools wheel
if errorlevel 1 exit /b 1

echo.
echo Installing Jupyter + kernel...
%VPY% -m pip install -U jupyterlab notebook ipykernel
if errorlevel 1 exit /b 1

echo.
echo Installing scientific stack...
%VPY% -m pip install -U numpy scipy matplotlib sympy
if errorlevel 1 exit /b 1

echo.
echo Installing FilterPy (used throughout notebooks)...
%VPY% -m pip install -U filterpy
if errorlevel 1 exit /b 1

echo.
echo Installing widgets (used by interact demos)...
%VPY% -m pip install -U ipywidgets
if errorlevel 1 exit /b 1

echo.
echo Installing notebook translation tool...
%VPY% -m pip install -U jupyter_translate
if errorlevel 1 exit /b 1

echo.
echo Patching jupyter_translate to keep code cells unchanged...
%VPY% -c "import inspect, pathlib, jupyter_translate; p=pathlib.Path(inspect.getsourcefile(jupyter_translate)); s=p.read_text(encoding='utf-8'); old=\"elif cell['cell_type'] == 'code':\\n            # For code cells, translate comments and print statements\"; new=\"elif cell['cell_type'] == 'code':\\n            # Do not translate code cells; keep source unchanged.\\n            continue\\n\\n            # For code cells, translate comments and print statements\"; print(' - file:', p); print(' - already patched' if 'Do not translate code cells' in s else ' - patching...'); (p.write_text(s.replace(old,new),encoding='utf-8') if old in s else None)"
if errorlevel 1 (
  echo WARNING: Patch step failed (translation may modify code cells).
)

echo.
echo Verifying imports...
%VPY% -c "import numpy, scipy, matplotlib, sympy; import filterpy; import ipywidgets; import jupyter_translate; print('OK: imports succeeded')"
if errorlevel 1 (
  echo ERROR: Import check failed.
  exit /b 1
)

echo.
echo Registering a Jupyter kernel (user-level)...
%VPY% -m ipykernel install --user --name kalman-book --display-name "Python (.venv) kalman-book"
if errorlevel 1 (
  echo WARNING: Kernel registration failed (you can still run Jupyter from the venv).
)

echo.
echo Done.
echo.
echo Next:
echo   1^) Activate venv: .venv\Scripts\activate
echo   2^) Start Jupyter: jupyter lab
echo.
exit /b 0
