#!/usr/bin/env bash
set -xe

VENV_DIR=venv
rm -rf ${VENV_DIR}
python -m virtualenv -p python ${VENV_DIR}

VENV_BIN_DIR=${VENV_DIR}/bin
${VENV_BIN_DIR}/python --version
${VENV_BIN_DIR}/python -m pip --version
# install dependencies in the venv
${VENV_BIN_DIR}/python -m pip install six protobuf

PYTHONPATH=ortools ${VENV_BIN_DIR}/python -c "import ortools"
PYTHONPATH=ortools ${VENV_BIN_DIR}/python -c "from ortools.linear_solver import pywraplp"

cp test.py.in ${VENV_DIR}/test.py
PYTHONPATH=. ${VENV_BIN_DIR}/python ${VENV_DIR}/test.py

rm -rf ${VENV_DIR}
#ldd ortools/linear_solver/../gen/ortools/linear_solver/_pywraplp.so
#objdump -p ortools/linear_solver/../gen/ortools/linear_solver/_pywraplp.so
#make install_python
