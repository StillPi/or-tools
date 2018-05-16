#!/usr/bin/env bash
set -xe

VENV_DIR=venv
rm -rf ${VENV_DIR}
python -m virtualenv -p python ${VENV_DIR}

VENV_BIN_DIR=${VENV_DIR}/bin
${VENV_BIN_DIR}/python --version
${VENV_BIN_DIR}/python -m pip --version

PYTHONPATH=ortools/gen ${VENV_BIN_DIR}/python -c "import ortools"
cp test.py.in ${VENV_DIR}/test.py
PYTHONPATH=ortools/gen ${VENV_BIN_DIR}/python ${VENV_DIR}/test.py
#make install_python
