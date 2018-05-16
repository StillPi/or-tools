#!/usr/bin/env bash
set -xe

VENV_DIR=venv
rm -rf ${VENV_DIR}
python -m virtualenv -p python ${VENV_DIR}

VENV_BIN_DIR=${VENV_DIR}/bin
${VENV_BIN_DIR}/python --version
${VENV_BIN_DIR}/python -m pip --version

PYTHONPATH=ortools ${VENV_BIN_DIR}/python -c "import ortools"
PYTHONPATH=ortools ${VENV_BIN_DIR}/python -v -c "from ortools.linear_solver import pywraplp"

cp test.py.in ${VENV_DIR}/test.py
PYTHONPATH=ortools ${VENV_BIN_DIR}/python ${VENV_DIR}/test.py
#ldd ortools/linear_solver/../gen/ortools/linear_solver/_pywraplp.so
#objdump -p ortools/linear_solver/../gen/ortools/linear_solver/_pywraplp.so
#make install_python
