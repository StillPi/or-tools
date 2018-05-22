#!/usr/bin/env bash
set -xe

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VENV_DIR="${DIR}/venv"
rm -rf "${VENV_DIR}"
python -m virtualenv -p python "${VENV_DIR}"

source "${VENV_DIR}/bin/activate"
python --version
python -m pip --version
# install dependencies in the venv
python -m pip install six protobuf

# Test ortools python from the build dir
python -c "import ortools"
python -c "from ortools.linear_solver import pywraplp"
cp test.py.in "${VENV_DIR}/test.py"
PYTHONPATH=. python "${VENV_DIR}/test.py"

# Try the wheel package
PYTHON_VERSION="$(python -c "from sys import version_info as v; print(str(v[0])+'.'+str(v[1]))")"
WHEEL_PKG="$(find "temp-python${PYTHON_VERSION}/ortools/dist/" -name "ortools-*.whl")"
python -m pip install "${WHEEL_PKG}"
python "${VENV_DIR}/test.py"

# Cleaning
deactivate
rm -rf "${VENV_DIR}"

# Misc
#ldd ortools/linear_solver/../gen/ortools/linear_solver/_pywraplp.so
#objdump -p ortools/linear_solver/../gen/ortools/linear_solver/_pywraplp.so
#make install_python
