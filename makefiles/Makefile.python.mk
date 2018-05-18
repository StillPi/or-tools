# ---------- Python support using SWIG ----------
.PHONY: help_python # Generate list of Python targets with descriptions.
help_python:
	@echo Use one of the following Python targets:
ifeq ($(SYSTEM),win)
	@tools\grep.exe "^.PHONY: .* #" $(CURDIR)/makefiles/Makefile.python.mk | tools\sed.exe "s/\.PHONY: \(.*\) # \(.*\)/\1\t\2/"
	@echo off & echo(
else
	@grep "^.PHONY: .* #" $(CURDIR)/makefiles/Makefile.python.mk | sed "s/\.PHONY: \(.*\) # \(.*\)/\1\t\2/" | expand -t24
	@echo
endif

OR_TOOLS_PYTHONPATH = $(OR_ROOT_FULL)$(CPSEP)$(OR_ROOT_FULL)$Sdependencies$Ssources$Sprotobuf-$(PROTOBUF_TAG)$Spython

# Check for required build tools
ifeq ($(SYSTEM),win)
PYTHON_COMPILER ?= python.exe
ifneq ($(WINDOWS_PATH_TO_PYTHON),)
PYTHON_EXECUTABLE := $(WINDOWS_PATH_TO_PYTHON)\$(PYTHON_COMPILER)
else
PYTHON_EXECUTABLE := $(shell $(WHICH) $(PYTHON_COMPILER) 2>nul)
endif
SET_PYTHONPATH = set PYTHONPATH=$(OR_TOOLS_PYTHONPATH) &&
else # UNIX
PYTHON_COMPILER ?= python$(UNIX_PYTHON_VER)
PYTHON_EXECUTABLE := $(shell which $(PYTHON_COMPILER))
SET_PYTHONPATH = PYTHONPATH=$(OR_TOOLS_PYTHONPATH)
endif

# Detect python3
ifneq ($(PYTHON_EXECUTABLE),)
ifeq ($(shell "$(PYTHON_EXECUTABLE)" -c "from sys import version_info as v; print (str(v[0]))"),3)
PYTHON3 := true
SWIG_PYTHON3_FLAG := -py3 -DPY3
PYTHON3_CFLAGS := -DPY3
endif
endif

.PHONY: python # Build Python OR-Tools.
.PHONY: test_python # Test Python OR-Tools using various examples.
.PHONY: install_python # Install Python OR-Tools on the host system
ifneq ($(PYTHON_EXECUTABLE),)
python: \
	ortoolslibs \
	install_python_modules \
	pyinit \
	pyalgorithms \
	pygraph \
	pycp \
	pylp \
	pysat \
	pyrcpsp

test_python: test_python_examples

install_python: pypi_archive
	cd "$(PYPI_ARCHIVE_TEMP_DIR)$Sortools" && "$(PYTHON_EXECUTABLE)" setup.py install --user

BUILT_LANGUAGES +=, Python$(PYTHON_VERSION)
else
python:
	@echo PYTHON_EXECUTABLE = "${PYTHON_EXECUTABLE}"
	$(warning Cannot find '$(PYTHON_COMPILER)' command which is needed for build. Please make sure it is installed and in system path.)

test_python: python
install_python: python
endif

.PHONY: clean_python # Clean Python output from previous build.
clean_python:
	-$(DEL) $(GEN_DIR)$Sortools$S__init__.py
	-$(DEL) ortools$S*.pyc
	-$(DELREC) ortools$S__pycache__
	-$(DEL) $(GEN_DIR)$Sortools$Salgorithms$S*.py
	-$(DEL) $(GEN_DIR)$Sortools$Salgorithms$S*.pyc
	-$(DELREC) $(GEN_DIR)$Sortools$Salgorithms$S__pycache__
	-$(DEL) ortools$Salgorithms$S*.pyc
	-$(DELREC) ortools$Salgorithms$S__pycache__
	-$(DEL) $(GEN_DIR)$Sortools$Salgorithms$S*_python_wrap.*
	-$(DEL) $(GEN_DIR)$Sortools$Salgorithms$S_pywrap*
	-$(DEL) $(GEN_DIR)$Sortools$Sgraph$S*.py
	-$(DEL) $(GEN_DIR)$Sortools$Sgraph$S*.pyc
	-$(DELREC) $(GEN_DIR)$Sortools$Sgraph$S__pycache__
	-$(DEL) ortools$Sgraph$S*.pyc
	-$(DELREC) ortools$Sgraph$S__pycache__
	-$(DEL) $(GEN_DIR)$Sortools$Sgraph$S*_python_wrap.*
	-$(DEL) $(GEN_DIR)$Sortools$Sgraph$S_pywrap*
	-$(DEL) $(GEN_DIR)$Sortools$Sconstraint_solver$S*.py
	-$(DEL) $(GEN_DIR)$Sortools$Sconstraint_solver$S*.pyc
	-$(DELREC) $(GEN_DIR)$Sortools$Sconstraint_solver$S__pycache__
	-$(DEL) ortools$Sconstraint_solver$S*.pyc
	-$(DELREC) ortools$Sconstraint_solver$S__pycache__
	-$(DEL) $(GEN_DIR)$Sortools$Sconstraint_solver$S*_python_wrap.*
	-$(DEL) $(GEN_DIR)$Sortools$Sconstraint_solver$S_pywrap*
	-$(DEL) $(GEN_DIR)$Sortools$Slinear_solver$S*.py
	-$(DEL) $(GEN_DIR)$Sortools$Slinear_solver$S*.pyc
	-$(DELREC) $(GEN_DIR)$Sortools$Slinear_solver$S__pycache__
	-$(DEL) ortools$Slinear_solver$S*.pyc
	-$(DELREC) ortools$Slinear_solver$S__pycache__
	-$(DEL) $(GEN_DIR)$Sortools$Slinear_solver$S*_python_wrap.*
	-$(DEL) $(GEN_DIR)$Sortools$Slinear_solver$S_pywrap*
	-$(DEL) $(GEN_DIR)$Sortools$Ssat$S*.py
	-$(DEL) $(GEN_DIR)$Sortools$Ssat$S*.pyc
	-$(DELREC) $(GEN_DIR)$Sortools$Ssat$S__pycache__
	-$(DEL) ortools$Ssat$S*.pyc
	-$(DELREC) ortools$Ssat$S__pycache__
	-$(DEL) ortools$Ssat$Spython$S*.pyc
	-$(DELREC) ortools$Ssat$Spython$S__pycache__
	-$(DEL) $(GEN_DIR)$Sortools$Ssat$S*_python_wrap.*
	-$(DEL) $(GEN_DIR)$Sortools$Ssat$S_pywrap*
	-$(DEL) $(GEN_DIR)$Sortools$Sdata$S*.py
	-$(DEL) $(GEN_DIR)$Sortools$Sdata$S*.pyc
	-$(DELREC) $(GEN_DIR)$Sortools$Sdata$S__pycache__
	-$(DEL) ortools$Sdata$S*.pyc
	-$(DELREC) ortools$Sdata$S__pycache__
	-$(DEL) $(GEN_DIR)$Sortools$Sdata$S*_python_wrap.*
	-$(DEL) $(GEN_DIR)$Sortools$Sdata$S_pywrap*
	-$(DEL) $(GEN_DIR)$Sortools$Sutil$S*.py
	-$(DEL) $(GEN_DIR)$Sortools$Sutil$S*.pyc
	-$(DELREC) $(GEN_DIR)$Sortools$Sutil$S__pycache__
	-$(DEL) ortools$Sutil$S*.pyc
	-$(DELREC) ortools$Sutil$S__pycache__
	-$(DEL) $(GEN_DIR)$Sortools$Sutil$S*_python_wrap.*
	-$(DEL) $(GEN_DIR)$Sortools$Sutil$S_pywrap*
	-$(DEL) $(LIB_DIR)$S_pywrap*.$(SWIG_LIB_SUFFIX)
	-$(DEL) $(OBJ_DIR)$Sswig$S*python_wrap.$O
	-$(DELREC) $(PYPI_ARCHIVE_TEMP_DIR)

.PHONY: install_python_modules
install_python_modules: dependencies/sources/protobuf-$(PROTOBUF_TAG)/python/google/protobuf/descriptor_pb2.py

dependencies/sources/protobuf-$(PROTOBUF_TAG)/python/google/protobuf/descriptor_pb2.py: \
dependencies/sources/protobuf-$(PROTOBUF_TAG)/python/setup.py
ifeq ($(SYSTEM),win)
	copy dependencies$Sinstall$Sbin$Sprotoc.exe dependencies$Ssources$Sprotobuf-$(PROTOBUF_TAG)$Ssrc
	cd dependencies$Ssources$Sprotobuf-$(PROTOBUF_TAG)$Spython && "$(PYTHON_EXECUTABLE)" setup.py build
endif
ifeq ($(PLATFORM),LINUX)
	cd dependencies$Ssources$Sprotobuf-$(PROTOBUF_TAG)$Spython && \
 LD_LIBRARY_PATH="$(UNIX_PROTOBUF_DIR)/lib":$(LD_LIBRARY_PATH) \
 PROTOC=$(PROTOC_BINARY) \
 "$(PYTHON_EXECUTABLE)" setup.py build
endif
ifeq ($(PLATFORM),MACOSX)
	cd dependencies$Ssources$Sprotobuf-$(PROTOBUF_TAG)$Spython && \
 DYLD_LIBRARY_PATH="$(UNIX_PROTOBUF_DIR)/lib":$(DYLD_LIBRARY_PATH) \
 PROTOC=$(PROTOC_BINARY) \
 "$(PYTHON_EXECUTABLE)" setup.py build
endif

.PHONY: pyinit
pyinit: $(GEN_DIR)/ortools/__init__.py

$(GEN_DIR)/ortools/__init__.py:
	$(COPY) ortools$S__init__.py $(GEN_DIR)$Sortools$S__init__.py

#######################
##  Python Wrappers  ##
#######################
# pywrapknapsack_solver
PYALGORITHMS_LIBS = $(LIB_DIR)/_pywrapknapsack_solver.$(SWIG_LIB_SUFFIX)
ifeq ($(PLATFORM),MACOSX)
PYALGORITHMS_LDFLAGS = -install_name @rpath/_pywrapknapsack_solver.$(SWIG_LIB_SUFFIX) #
endif
pyalgorithms: $(PYALGORITHMS_LIBS)

$(GEN_DIR)/ortools/algorithms/pywrapknapsack_solver.py: \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/util/python/vector.i \
 $(SRC_DIR)/ortools/algorithms/python/knapsack_solver.i \
 $(SRC_DIR)/ortools/algorithms/knapsack_solver.h
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -python $(SWIG_PYTHON3_FLAG) \
 -o $(GEN_DIR)$Sortools$Salgorithms$Sknapsack_solver_python_wrap.cc \
 -module pywrapknapsack_solver \
 ortools$Salgorithms$Spython$Sknapsack_solver.i

$(GEN_DIR)/ortools/algorithms/knapsack_solver_python_wrap.cc: \
 $(GEN_DIR)/ortools/algorithms/pywrapknapsack_solver.py

$(OBJ_DIR)/swig/knapsack_solver_python_wrap.$O: \
 $(GEN_DIR)/ortools/algorithms/knapsack_solver_python_wrap.cc \
 $(ALGORITHMS_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) $(PYTHON3_CFLAGS) \
 -c $(GEN_DIR)$Sortools$Salgorithms$Sknapsack_solver_python_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Sknapsack_solver_python_wrap.$O

$(PYALGORITHMS_LIBS): $(OBJ_DIR)/swig/knapsack_solver_python_wrap.$O $(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) \
 $(PYALGORITHMS_LDFLAGS) \
 $(LD_OUT)$(LIB_DIR)$S_pywrapknapsack_solver.$(SWIG_LIB_SUFFIX) \
 $(OBJ_DIR)$Sswig$Sknapsack_solver_python_wrap.$O \
 $(OR_TOOLS_LNK) \
 $(SYS_LNK) \
 $(PYTHON_LNK) \
 $(PYTHON_LDFLAGS)
ifeq ($(SYSTEM),win)
	copy $(LIB_DIR)$S_pywrapknapsack_solver.$(SWIG_LIB_SUFFIX) $(GEN_DIR)\\ortools\\algorithms\\_pywrapknapsack_solver.pyd
else
	cp $(PYALGORITHMS_LIBS) $(GEN_DIR)/ortools/algorithms
endif

# pywrapgraph
PYGRAPH_LIBS = $(LIB_DIR)/_pywrapgraph.$(SWIG_LIB_SUFFIX)
ifeq ($(PLATFORM),MACOSX)
PYGRAPH_LDFLAGS = -install_name @rpath/_pywrapgraph.$(SWIG_LIB_SUFFIX) #
endif
pygraph: $(PYGRAPH_LIBS)

$(GEN_DIR)/ortools/graph/pywrapgraph.py: \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/util/python/vector.i \
 $(SRC_DIR)/ortools/graph/python/graph.i \
 $(SRC_DIR)/ortools/graph/min_cost_flow.h \
 $(SRC_DIR)/ortools/graph/max_flow.h \
 $(SRC_DIR)/ortools/graph/ebert_graph.h \
 $(SRC_DIR)/ortools/graph/shortestpaths.h
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -python $(SWIG_PYTHON3_FLAG) \
 -o $(GEN_DIR)$Sortools$Sgraph$Sgraph_python_wrap.cc \
 -module pywrapgraph \
 ortools$Sgraph$Spython$Sgraph.i

$(GEN_DIR)/ortools/graph/graph_python_wrap.cc: \
 $(GEN_DIR)/ortools/graph/pywrapgraph.py

$(OBJ_DIR)/swig/graph_python_wrap.$O: \
 $(GEN_DIR)/ortools/graph/graph_python_wrap.cc \
 $(GRAPH_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) $(PYTHON3_CFLAGS) \
 -c $(GEN_DIR)/ortools/graph/graph_python_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Sgraph_python_wrap.$O

$(PYGRAPH_LIBS): $(OBJ_DIR)/swig/graph_python_wrap.$O $(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) \
 $(PYGRAPH_LDFLAGS) \
 $(LD_OUT)$(LIB_DIR)$S_pywrapgraph.$(SWIG_LIB_SUFFIX) \
 $(OBJ_DIR)$Sswig$Sgraph_python_wrap.$O \
 $(OR_TOOLS_LNK) \
 $(SYS_LNK) \
 $(PYTHON_LNK) \
 $(PYTHON_LDFLAGS)
ifeq ($(SYSTEM),win)
	copy $(LIB_DIR)$S_pywrapgraph.$(SWIG_LIB_SUFFIX) $(GEN_DIR)\\ortools\\graph\\_pywrapgraph.pyd
else
	cp $(PYGRAPH_LIBS) $(GEN_DIR)/ortools/graph
endif

# pywrapcp
PYCP_LIBS = $(LIB_DIR)/_pywrapcp.$(SWIG_LIB_SUFFIX)
ifeq ($(PLATFORM),MACOSX)
PYCP_LDFLAGS = -install_name @rpath/_pywrapcp.$(SWIG_LIB_SUFFIX) #
endif
pycp: $(PYCP_LIBS)

$(GEN_DIR)/ortools/constraint_solver/search_limit_pb2.py: \
 $(SRC_DIR)/ortools/constraint_solver/search_limit.proto
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Ssearch_limit.proto

$(GEN_DIR)/ortools/constraint_solver/model_pb2.py: \
 $(SRC_DIR)/ortools/constraint_solver/model.proto \
 $(GEN_DIR)/ortools/constraint_solver/search_limit_pb2.py
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Smodel.proto

$(GEN_DIR)/ortools/constraint_solver/assignment_pb2.py: \
 $(SRC_DIR)/ortools/constraint_solver/assignment.proto
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Sassignment.proto

$(GEN_DIR)/ortools/constraint_solver/solver_parameters_pb2.py: \
 $(SRC_DIR)/ortools/constraint_solver/solver_parameters.proto
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Ssolver_parameters.proto

$(GEN_DIR)/ortools/constraint_solver/routing_enums_pb2.py: \
 $(SRC_DIR)/ortools/constraint_solver/routing_enums.proto
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Srouting_enums.proto

$(GEN_DIR)/ortools/constraint_solver/routing_parameters_pb2.py: \
 $(SRC_DIR)/ortools/constraint_solver/routing_parameters.proto \
 $(GEN_DIR)/ortools/constraint_solver/solver_parameters_pb2.py \
 $(GEN_DIR)/ortools/constraint_solver/routing_enums_pb2.py
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Srouting_parameters.proto

$(GEN_DIR)/ortools/constraint_solver/pywrapcp.py: \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/util/python/vector.i \
 $(SRC_DIR)/ortools/constraint_solver/python/constraint_solver.i \
 $(SRC_DIR)/ortools/constraint_solver/python/routing.i \
 $(SRC_DIR)/ortools/constraint_solver/constraint_solver.h \
 $(SRC_DIR)/ortools/constraint_solver/constraint_solveri.h \
 $(GEN_DIR)/ortools/constraint_solver/assignment_pb2.py \
 $(GEN_DIR)/ortools/constraint_solver/model_pb2.py \
 $(GEN_DIR)/ortools/constraint_solver/routing_enums_pb2.py \
 $(GEN_DIR)/ortools/constraint_solver/routing_parameters_pb2.py \
 $(GEN_DIR)/ortools/constraint_solver/search_limit_pb2.py \
 $(GEN_DIR)/ortools/constraint_solver/solver_parameters_pb2.py \
 $(GEN_DIR)/ortools/constraint_solver/assignment.pb.h \
 $(GEN_DIR)/ortools/constraint_solver/model.pb.h \
 $(GEN_DIR)/ortools/constraint_solver/search_limit.pb.h \
 $(CP_LIB_OBJS)
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -python $(SWIG_PYTHON3_FLAG) \
 -o $(GEN_DIR)$Sortools$Sconstraint_solver$Sconstraint_solver_python_wrap.cc \
 -module pywrapcp \
 $(SRC_DIR)/ortools/constraint_solver$Spython$Srouting.i

$(GEN_DIR)/ortools/constraint_solver/constraint_solver_python_wrap.cc: \
 $(GEN_DIR)/ortools/constraint_solver/pywrapcp.py

$(OBJ_DIR)/swig/constraint_solver_python_wrap.$O: \
 $(GEN_DIR)/ortools/constraint_solver/constraint_solver_python_wrap.cc \
 $(CP_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) $(PYTHON3_CFLAGS) \
 -c $(GEN_DIR)$Sortools$Sconstraint_solver$Sconstraint_solver_python_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Sconstraint_solver_python_wrap.$O

$(PYCP_LIBS): $(OBJ_DIR)/swig/constraint_solver_python_wrap.$O $(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) \
 $(PYCP_LDFLAGS) \
 $(LD_OUT)$(LIB_DIR)$S_pywrapcp.$(SWIG_LIB_SUFFIX) \
 $(OBJ_DIR)$Sswig$Sconstraint_solver_python_wrap.$O \
 $(OR_TOOLS_LNK) \
 $(SYS_LNK) \
 $(PYTHON_LNK) \
 $(PYTHON_LDFLAGS)
ifeq ($(SYSTEM),win)
	copy $(LIB_DIR)$S_pywrapcp.$(SWIG_LIB_SUFFIX) $(GEN_DIR)\\ortools\\constraint_solver\\_pywrapcp.pyd
else
	cp $(PYCP_LIBS) $(GEN_DIR)/ortools/constraint_solver
endif

# pywraplp
PYLP_LIBS = $(LIB_DIR)/_pywraplp.$(SWIG_LIB_SUFFIX)
ifeq ($(PLATFORM),MACOSX)
PYLP_LDFLAGS = -install_name @rpath/_pywraplp.$(SWIG_LIB_SUFFIX) #
endif
pylp: $(PYLP_LIBS)

$(GEN_DIR)/ortools/util/optional_boolean_pb2.py: \
 $(SRC_DIR)/ortools/util/optional_boolean.proto
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)/ortools/util/optional_boolean.proto

$(GEN_DIR)/ortools/linear_solver/linear_solver_pb2.py: \
 $(SRC_DIR)/ortools/linear_solver/linear_solver.proto \
 $(GEN_DIR)/ortools/util/optional_boolean_pb2.py
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)/ortools/linear_solver/linear_solver.proto

$(GEN_DIR)/ortools/linear_solver/pywraplp.py: \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/util/python/vector.i \
 $(SRC_DIR)/ortools/linear_solver/python/linear_solver.i \
 $(SRC_DIR)/ortools/linear_solver/linear_solver.h \
 $(GEN_DIR)/ortools/linear_solver/linear_solver.pb.h \
 $(GEN_DIR)/ortools/linear_solver/linear_solver_pb2.py
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -python $(SWIG_PYTHON3_FLAG) \
 -o $(GEN_DIR)$Sortools$Slinear_solver$Slinear_solver_python_wrap.cc \
 -module pywraplp \
 $(SRC_DIR)/ortools/linear_solver$Spython$Slinear_solver.i

$(GEN_DIR)/ortools/linear_solver/linear_solver_python_wrap.cc: \
 $(GEN_DIR)/ortools/linear_solver/pywraplp.py

$(OBJ_DIR)/swig/linear_solver_python_wrap.$O: \
 $(GEN_DIR)/ortools/linear_solver/linear_solver_python_wrap.cc \
 $(LP_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) $(PYTHON3_CFLAGS) \
 -c $(GEN_DIR)$Sortools$Slinear_solver$Slinear_solver_python_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Slinear_solver_python_wrap.$O

$(PYLP_LIBS): $(OBJ_DIR)/swig/linear_solver_python_wrap.$O $(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) \
 $(PYLP_LDFLAGS) \
 $(LD_OUT)$(LIB_DIR)$S_pywraplp.$(SWIG_LIB_SUFFIX) \
 $(OBJ_DIR)$Sswig$Slinear_solver_python_wrap.$O \
 $(OR_TOOLS_LNK) \
 $(SYS_LNK) \
 $(PYTHON_LNK) \
 $(PYTHON_LDFLAGS)
ifeq ($(SYSTEM),win)
	copy $(LIB_DIR)$S_pywraplp.$(SWIG_LIB_SUFFIX) $(GEN_DIR)\\ortools\\linear_solver\\_pywraplp.pyd
else
	cp $(PYLP_LIBS) $(GEN_DIR)/ortools/linear_solver
endif

# pywrapsat
PYSAT_LIBS = $(LIB_DIR)/_pywrapsat.$(SWIG_LIB_SUFFIX)
ifeq ($(PLATFORM),MACOSX)
PYSAT_LDFLAGS = -install_name @rpath/_pywrapsat.$(SWIG_LIB_SUFFIX) #
endif
pysat: $(PYSAT_LIBS)

$(GEN_DIR)/ortools/sat/cp_model_pb2.py: \
 $(SRC_DIR)/ortools/sat/cp_model.proto
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)/ortools/sat/cp_model.proto

$(GEN_DIR)/ortools/sat/sat_parameters_pb2.py: \
 $(SRC_DIR)/ortools/sat/sat_parameters.proto
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)/ortools/sat/sat_parameters.proto

$(GEN_DIR)/ortools/sat/pywrapsat.py: \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/util/python/vector.i \
 $(SRC_DIR)/ortools/sat/python/sat.i \
 $(GEN_DIR)/ortools/sat/cp_model_pb2.py \
 $(GEN_DIR)/ortools/sat/sat_parameters_pb2.py \
 $(SAT_DEPS)
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -python $(SWIG_PYTHON3_FLAG) \
 -o $(GEN_DIR)$Sortools$Ssat$Ssat_python_wrap.cc \
 -module pywrapsat \
 $(SRC_DIR)/ortools/sat$Spython$Ssat.i

$(GEN_DIR)/ortools/sat/sat_python_wrap.cc: \
 $(GEN_DIR)/ortools/sat/pywrapsat.py

$(OBJ_DIR)/swig/sat_python_wrap.$O: \
 $(GEN_DIR)/ortools/sat/sat_python_wrap.cc \
 $(SAT_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) $(PYTHON3_CFLAGS) \
 -c $(GEN_DIR)$Sortools$Ssat$Ssat_python_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Ssat_python_wrap.$O

$(PYSAT_LIBS): $(OBJ_DIR)/swig/sat_python_wrap.$O $(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) \
 $(PYSAT_LDFLAGS) \
 $(LD_OUT)$(LIB_DIR)$S_pywrapsat.$(SWIG_LIB_SUFFIX) \
 $(OBJ_DIR)$Sswig$Ssat_python_wrap.$O \
 $(OR_TOOLS_LNK) \
 $(SYS_LNK) \
 $(PYTHON_LNK) \
 $(PYTHON_LDFLAGS)
ifeq ($(SYSTEM),win)
	copy $(LIB_DIR)$S_pywrapsat.$(SWIG_LIB_SUFFIX) $(GEN_DIR)\\ortools\\sat\\_pywrapsat.pyd
else
	cp $(PYSAT_LIBS) $(GEN_DIR)/ortools/sat
endif

# pywraprcpsp
PYRCPSP_LIBS = $(LIB_DIR)/_pywraprcpsp.$(SWIG_LIB_SUFFIX)
ifeq ($(PLATFORM),MACOSX)
PYRCPSP_LDFLAGS = -install_name @rpath/_pywraprcpsp.$(SWIG_LIB_SUFFIX) #
endif
pyrcpsp: $(PYRCPSP_LIBS)

$(GEN_DIR)/ortools/data/rcpsp_pb2.py: \
 $(SRC_DIR)/ortools/data/rcpsp.proto
	$(PROTOC) --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) \
 $(SRC_DIR)/ortools/data/rcpsp.proto

$(GEN_DIR)/ortools/data/pywraprcpsp.py: \
 $(SRC_DIR)/ortools/data/rcpsp_parser.h \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/data/python/rcpsp.i \
 $(GEN_DIR)/ortools/data/rcpsp_pb2.py \
 $(DATA_DEPS)
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -python $(SWIG_PYTHON3_FLAG) \
 -o $(GEN_DIR)$Sortools$Sdata$Srcpsp_python_wrap.cc \
 -module pywraprcpsp \
 $(SRC_DIR)/ortools/data$Spython$Srcpsp.i

$(GEN_DIR)/ortools/data/rcpsp_python_wrap.cc: \
 $(GEN_DIR)/ortools/data/pywraprcpsp.py

$(OBJ_DIR)/swig/rcpsp_python_wrap.$O: \
 $(GEN_DIR)/ortools/data/rcpsp_python_wrap.cc \
 $(DATA_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) $(PYTHON3_CFLAGS) \
 -c $(GEN_DIR)$Sortools$Sdata$Srcpsp_python_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Srcpsp_python_wrap.$O

$(PYRCPSP_LIBS): $(OBJ_DIR)/swig/rcpsp_python_wrap.$O $(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) \
 $(PYRCPSP_LDFLAGS) \
 $(LD_OUT)$(LIB_DIR)$S_pywraprcpsp.$(SWIG_LIB_SUFFIX) \
 $(OBJ_DIR)$Sswig$Srcpsp_python_wrap.$O \
 $(OR_TOOLS_LNK) \
 $(SYS_LNK) \
 $(PYTHON_LNK) \
 $(PYTHON_LDFLAGS)
ifeq ($(SYSTEM),win)
	copy $(LIB_DIR)$S_pywraprcpsp.$(SWIG_LIB_SUFFIX) $(GEN_DIR)\\ortools\\data\\_pywraprcpsp.pyd
else
	cp $(PYRCPSP_LIBS) $(GEN_DIR)/ortools/data
endif

# Run a single example
rpy: $(PYLP_LIBS) $(PYCP_LIBS) $(PYGRAPH_LIBS) $(PYALGORITHMS_LIBS) $(PYSAT_LIBS) $(PYRCPSP_LIBS) $(EX)
	$(SET_PYTHONPATH) "$(PYTHON_EXECUTABLE)" $(EX) $(ARGS)

.PHONY: python_examples_archive # Build stand-alone Python examples archive file for redistribution.
python_examples_archive:
	-$(DELREC) temp
	$(MKDIR) temp
	$(MKDIR) temp$Sortools_examples
	$(MKDIR) temp$Sortools_examples$Sexamples
	$(MKDIR) temp$Sortools_examples$Sexamples$Spython
	$(MKDIR) temp$Sortools_examples$Sexamples$Snotebook
	$(MKDIR) temp$Sortools_examples$Sexamples$Sdata
	$(COPY) examples$Spython$S*.py temp$Sortools_examples$Sexamples$Spython
	$(COPY) examples$Snotebook$S*.ipynb temp$Sortools_examples$Sexamples$Snotebook
	$(COPY) examples$Snotebook$S*.md temp$Sortools_examples$Sexamples$Snotebook
	$(COPY) tools$SREADME.examples.python temp$Sortools_examples$SREADME.txt
	$(COPY) LICENSE-2.0.txt temp$Sortools_examples
ifeq ($(SYSTEM),win)
	cd temp\ortools_examples && ..\..\tools\tar.exe -C ..\.. -c -v --exclude *svn* --exclude *roadef* --exclude *vector_packing* examples\data | ..\..\tools\tar.exe xvm
	cd temp && ..\tools\zip.exe -r ..\or-tools_python_examples_v$(OR_TOOLS_VERSION).zip ortools_examples
else
	cd temp/ortools_examples && tar -C ../.. -c -v --exclude *svn* --exclude *roadef* --exclude *vector_packing* examples/data | tar xvm
	cd temp && tar -c -v -z --no-same-owner -f ../or-tools_python_examples$(PYPI_OS)_v$(OR_TOOLS_VERSION).tar.gz ortools_examples
endif

#####################
##  Pypi artifact  ##
#####################
.PHONY: pypi_archive # Create Python "ortools" wheel package
PYPI_ARCHIVE_TEMP_DIR = temp-python$(PYTHON_VERSION)
pypi_archive: python $(PYPI_ARCHIVE_TEMP_DIR)
ifneq ($(SYSTEM),win)
	cp $(OR_TOOLS_LIBS) $(PYPI_ARCHIVE_TEMP_DIR)/ortools/ortools
endif
ifeq ($(UNIX_GFLAGS_DIR),$(OR_TOOLS_TOP)/dependencies/install)
	$(COPYREC) dependencies$Sinstall$Slib$Slibgflags* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
endif
ifeq ($(UNIX_GLOG_DIR),$(OR_TOOLS_TOP)/dependencies/install)
	$(COPYREC) dependencies$Sinstall$Slib$Slibglog* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
endif
ifeq ($(UNIX_PROTOBUF_DIR),$(OR_TOOLS_TOP)/dependencies/install)
	$(COPYREC) dependencies$Sinstall$Slib$Slibproto* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
endif
ifeq ($(UNIX_CBC_DIR),$(OR_TOOLS_TOP)/dependencies/install)
	$(COPYREC) dependencies$Sinstall$Slib$SlibCbc* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
	$(COPYREC) dependencies$Sinstall$Slib$SlibCgl* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
	$(COPYREC) dependencies$Sinstall$Slib$SlibClp* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
	$(COPYREC) dependencies$Sinstall$Slib$SlibOsi* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
	$(COPYREC) dependencies$Sinstall$Slib$SlibCoinUtils* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
endif

OR_TOOLS_PYTHON_GEN_SCRIPTS = $(wildcard $(GEN_DIR)/ortools/*/*.py) $(wildcard $(GEN_DIR)/ortools/*/*.cc)
$(PYPI_ARCHIVE_TEMP_DIR): $(OR_TOOLS_PYTHON_GEN_SCRIPTS)
	-$(DELREC) $(PYPI_ARCHIVE_TEMP_DIR)
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
	$(COPY) tools$Ssetup.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
	$(SED) -i -e 's/ORTOOLS_PYTHON_VERSION/ortools$(PYPI_OS)/' $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Ssetup.py
	$(SED) -i -e 's/VVVV/$(OR_TOOLS_VERSION)/' $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Ssetup.py
	$(SED) -i -e 's/PROTOBUF_TAG/$(PROTOBUF_TAG)/' $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Ssetup.py
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools
	$(COPY) $(GEN_DIR)$Sortools$S__init__.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$S__init__.py
	$(COPY) tools$SREADME.pypi $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$SREADME.txt
	$(COPY) LICENSE-2.0.txt $(PYPI_ARCHIVE_TEMP_DIR)$Sortools
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Salgorithms
	$(TOUCH) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Salgorithms$S__init__.py
	$(COPY) $(GEN_DIR)$Sortools$Salgorithms$Spywrapknapsack_solver.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Salgorithms
	$(COPY) $(GEN_DIR)$Sortools$Salgorithms$S_pywrapknapsack_solver.* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Salgorithms
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sgraph
	$(TOUCH) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sgraph$S__init__.py
	$(COPY) $(GEN_DIR)$Sortools$Sgraph$Spywrapgraph.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sgraph
	$(COPY) $(GEN_DIR)$Sortools$Sgraph$S_pywrapgraph.* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sgraph
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sconstraint_solver
	$(TOUCH) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sconstraint_solver$S__init__.py
	$(COPY) $(GEN_DIR)$Sortools$Sconstraint_solver$S*.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sconstraint_solver
	$(COPY) $(GEN_DIR)$Sortools$Sconstraint_solver$S_pywrapcp.* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sconstraint_solver
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Slinear_solver
	$(TOUCH) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Slinear_solver$S__init__.py
	$(COPY) ortools$Slinear_solver$S*.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Slinear_solver
	$(COPY) $(GEN_DIR)$Sortools$Slinear_solver$S*.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Slinear_solver
	$(COPY) $(GEN_DIR)$Sortools$Slinear_solver$S_pywraplp.* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Slinear_solver
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Ssat
	$(TOUCH) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Ssat$S__init__.py
	$(COPY) ortools$Ssat$S*.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Ssat
	$(COPY) $(GEN_DIR)$Sortools$Ssat$S*.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Ssat
	$(COPY) $(GEN_DIR)$Sortools$Ssat$S_pywrapsat.* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Ssat
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Ssat$Spython
	$(COPY) ortools$Ssat$Spython$S*.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Ssat$Spython
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sdata
	$(TOUCH) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sdata$S__init__.py
	$(COPY) $(GEN_DIR)$Sortools$Sdata$S*.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sdata
	$(COPY) $(GEN_DIR)$Sortools$Sdata$S_pywraprcpsp.* $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sdata
	$(MKDIR) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sutil
	$(TOUCH) $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sutil$S__init__.py
	$(COPY) $(GEN_DIR)$Sortools$Sutil$S*.py $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$Sutil
ifeq ($(SYSTEM),win)
	echo __version__ = "$(OR_TOOLS_VERSION)" >> $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$S__init__.py
	$(SED) -i -e 's/\.dll/\.pyd/' $(PYPI_ARCHIVE_TEMP_DIR)/ortools/setup.py
	$(SED) -i -e '/DELETEWIN/d' $(PYPI_ARCHIVE_TEMP_DIR)/ortools/setup.py
	$(SED) -i -e 's/DELETEUNIX/          /g' $(PYPI_ARCHIVE_TEMP_DIR)/ortools/setup.py
	-del $(PYPI_ARCHIVE_TEMP_DIR)\ortools\setup.py-e
else
	echo "__version__ = \"$(OR_TOOLS_VERSION)\"" >> $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$S__init__.py
	$(SED) -i -e 's/\.dll/\.so/' $(PYPI_ARCHIVE_TEMP_DIR)/ortools/setup.py
	$(SED) -i -e 's/DELETEWIN //g' $(PYPI_ARCHIVE_TEMP_DIR)/ortools/setup.py
	$(SED) -i -e '/DELETEUNIX/d' $(PYPI_ARCHIVE_TEMP_DIR)/ortools/setup.py
	$(SED) -i -e 's/DLL/$L/g' $(PYPI_ARCHIVE_TEMP_DIR)/ortools/setup.py
endif
#	$(SED) -i -e 's/VVVV/$(OR_TOOLS_VERSION)/' $(PYPI_ARCHIVE_TEMP_DIR)$Sortools$Sortools$S__init__.py

pypi_upload: pypi_archive
	@echo Uploading Pypi module for "$(PYTHON_EXECUTABLE)".
ifeq ($(SYSTEM),win)
	cd $(PYPI_ARCHIVE_TEMP_DIR)\ortools && "$(PYTHON_EXECUTABLE)" setup.py bdist_wheel bdist_wininst
else
  ifeq ($(PLATFORM),MACOSX)
	cd $(PYPI_ARCHIVE_TEMP_DIR)/ortools && "$(PYTHON_EXECUTABLE)" setup.py bdist_wheel
  else
	cd $(PYPI_ARCHIVE_TEMP_DIR)/ortools && "$(PYTHON_EXECUTABLE)" setup.py bdist_egg
  endif
endif
	cd $(PYPI_ARCHIVE_TEMP_DIR)/ortools && twine upload dist/*

.PHONY: detect_python # Show variables used to build Python OR-Tools.
detect_python:
	@echo Relevant info for the Python build:
ifeq ($(SYSTEM),win)
	@echo WINDOWS_PATH_TO_PYTHON = "$(WINDOWS_PATH_TO_PYTHON)"
else
	@echo UNIX_PYTHON_VER = "$(UNIX_PYTHON_VER)"
endif
	@echo PYTHON_COMPILER = $(PYTHON_COMPILER)
	@echo PYTHON_EXECUTABLE = "$(PYTHON_EXECUTABLE)"
	@echo PYTHON_VERSION = $(PYTHON_VERSION)
	@echo PYTHON3 = $(PYTHON3)
	@echo PYTHON_INC = $(PYTHON_INC)
	@echo PYTHON_LNK = $(PYTHON_LNK)
	@echo PYTHON_LDFLAGS = $(PYTHON_LDFLAGS)
	@echo SWIG_BINARY = $(SWIG_BINARY)
	@echo SWIG_INC = $(SWIG_INC)
	@echo SWIG_PYTHON3_FLAG = $(SWIG_PYTHON3_FLAG)
	@echo SET_PYTHONPATH = "$(SET_PYTHONPATH)"
ifeq ($(SYSTEM),win)
	@echo off & echo(
else
	@echo
endif
