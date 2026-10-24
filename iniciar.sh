#!/usr/bin/env bash
# Cria o ambiente virtual (se preciso), instala as dependências e inicia o J.A.R.V.I.S.
# Uso: ./iniciar.sh        (defina PYTHON=python3.12 para escolher o interpretador)
set -euo pipefail
cd "$(dirname "$0")"

PY="${PYTHON:-python3}"
if ! command -v "$PY" >/dev/null 2>&1; then
  echo "Python não encontrado ('$PY'). Instale o Python 3.10 ou superior." >&2
  exit 1
fi

if [ ! -d .venv ]; then
  echo "Criando ambiente virtual..."
  "$PY" -m venv .venv
fi
# shellcheck disable=SC1091
source .venv/bin/activate

if ! python -c "import tkinter" >/dev/null 2>&1; then
  echo "Tkinter não encontrado. No Debian/Ubuntu: sudo apt install python3-tk" >&2
  exit 1
fi

python -m pip install --quiet --upgrade pip
python -m pip install --quiet -r requirements.txt

[ -f jarvis.env ] || cp jarvis.env.example jarvis.env

exec python jarvis.py
