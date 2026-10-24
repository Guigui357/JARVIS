@echo off
setlocal
cd /d "%~dp0"

if not exist ".venv" (
  echo Criando ambiente virtual...
  py -3 -m venv .venv 2>nul || python -m venv .venv
  if errorlevel 1 (
    echo Falha ao criar o ambiente virtual. Instale o Python 3.10 ou superior e tente novamente.
    pause
    exit /b 1
  )
)

call ".venv\Scripts\activate.bat"
python -m pip install --quiet --upgrade pip
python -m pip install --quiet -r requirements.txt
if errorlevel 1 (
  echo Falha ao instalar as dependencias.
  pause
  exit /b 1
)

if not exist "jarvis.env" copy "jarvis.env.example" "jarvis.env" >nul

python jarvis.py
if errorlevel 1 pause
endlocal
