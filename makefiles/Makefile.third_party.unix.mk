.PHONY: help_third_party # Generate list of Prerequisite targets with descriptions.
help_third_party:
	@echo Use one of the following Prerequisite targets:
	@grep "^.PHONY: .* #" $(CURDIR)/makefiles/Makefile.third_party.unix.mk | sed "s/\.PHONY: \(.*\) # \(.*\)/\1\t\2/" | expand -t20
	@echo

# Checks if the user has overwritten default libraries and binaries.
UNIX_GFLAGS_DIR ?= $(OR_TOOLS_TOP)/dependencies/install
UNIX_GLOG_DIR ?= $(OR_TOOLS_TOP)/dependencies/install
UNIX_PROTOBUF_DIR ?= $(OR_TOOLS_TOP)/dependencies/install
UNIX_PROTOC_BINARY ?= $(UNIX_PROTOBUF_DIR)/bin/protoc
UNIX_CBC_DIR ?= $(OR_TOOLS_TOP)/dependencies/install
UNIX_CGL_DIR ?= $(UNIX_CBC_DIR)
UNIX_CLP_DIR ?= $(UNIX_CBC_DIR)
UNIX_OSI_DIR ?= $(UNIX_CBC_DIR)
UNIX_COINUTILS_DIR ?= $(UNIX_CBC_DIR)
UNIX_SWIG_BINARY ?= swig
PROTOC_BINARY := $(shell $(WHICH) ${UNIX_PROTOC_BINARY})

# Tags of dependencies to checkout.
GFLAGS_TAG = 2.2.1
GLOG_TAG = 0.3.5
PROTOBUF_TAG = 3.5.1
CBC_TAG = 2.9.9
CGL_TAG = 0.59.10
CLP_TAG = 1.16.11
OSI_TAG = 0.107.9
COINUTILS_TAG = 2.10.14
PATCHELF_TAG = 0.9

# Main target.
.PHONY: third_party # Build OR-Tools Prerequisite
third_party: makefile_third_party build_third_party

.PHONY: third_party_check # Check if "make third_party" have been run or not
third_party_check:
ifeq ($(wildcard $(UNIX_GFLAGS_DIR)/include/gflags/gflags.h),)
	$(error Third party GFlags files was not found! did you run 'make third_party' or set UNIX_GFLAGS_DIR ?)
endif
ifeq ($(wildcard $(UNIX_GLOG_DIR)/include/glog/logging.h),)
	$(error Third party GLog files was not found! did you run 'make third_party' or set UNIX_GLOG_DIR ?)
endif
ifeq ($(wildcard $(UNIX_PROTOBUF_DIR)/include/google/protobuf/descriptor.h),)
	$(error Third party Protobuf files was not found! did you run 'make third_party' or set UNIX_PROTOBUF_DIR ?)
endif
ifeq ($(wildcard $(PROTOC_BINARY)),)
	$(error Cannot find $(UNIX_PROTOC_BINARY). Please verify UNIX_PROTOC_BINARY)
endif
ifeq ($(wildcard $(UNIX_CBC_DIR)/include/cbc/coin/CbcModel.hpp $(UNIX_CBC_DIR)/include/coin/CbcModel.hpp),)
	$(error Third party Cbc files was not found! did you run 'make third_party' or set UNIX_CBC_DIR ?)
endif
ifeq ($(wildcard $(UNIX_CGL_DIR)/include/cgl/coin/CglParam.hpp $(UNIX_CGL_DIR)/include/coin/CglParam.hpp),)
	$(error Third party Cgl files was not found! did you run 'make third_party' or set UNIX_CGL_DIR ?)
endif
ifeq ($(wildcard $(UNIX_CLP_DIR)/include/clp/coin/ClpModel.hpp $(UNIX_CLP_DIR)/include/coin/ClpSimplex.hpp),)
	$(error Third party Clp files was not found! did you run 'make third_party' or set UNIX_CLP_DIR ?)
endif
ifeq ($(wildcard $(UNIX_OSI_DIR)/include/osi/coin/OsiSolverInterface.hpp $(UNIX_OSI_DIR)/include/coin/OsiSolverInterface.hpp),)
	$(error Third party Osi files was not found! did you run 'make third_party' or set UNIX_OSI_DIR ?)
endif
ifeq ($(wildcard $(UNIX_COINUTILS_DIR)/include/coinutils/coin/CoinModel.hpp $(UNIX_COINUTILS_DIR)/include/coin/CoinModel.hpp),)
	$(error Third party CoinUtils files was not found! did you run 'make third_party' or set UNIX_COINUTILS_DIR ?)
endif
	$(info All third parties found !)

.PHONY: build_third_party
build_third_party: \
 archives_directory \
 install_deps_directories \
 build_gflags \
 build_glog \
 build_protobuf \
 build_cbc

.PHONY: archives_directory
archives_directory: dependencies/archives

dependencies/archives:
	$(MKDIR_P) dependencies$Sarchives

.PHONY: install_deps_directories
install_deps_directories: \
 dependencies/install/bin \
 dependencies/install/lib \
 dependencies/install/include/coin

dependencies/install:
	$(MKDIR_P) dependencies$Sinstall

dependencies/install/bin: | dependencies/install
	$(MKDIR_P) dependencies$Sinstall$Sbin

dependencies/install/lib: | dependencies/install
	$(MKDIR_P) dependencies$Sinstall$Slib

dependencies/install/include: | dependencies/install
	$(MKDIR_P) dependencies$Sinstall$Sinclude

dependencies/install/include/coin: | dependencies/install/include
	$(MKDIR_P) dependencies$Sinstall$Sinclude$Scoin

##############
##  GFLAGS  ##
##############
# This uses gflags cmake-based build.
build_gflags: dependencies/install/lib/libgflags.$L

dependencies/install/lib/libgflags.$L: dependencies/sources/gflags-$(GFLAGS_TAG) | dependencies/install
	cd dependencies/sources/gflags-$(GFLAGS_TAG) && \
  $(SET_COMPILER) $(CMAKE) -H. -Bbuild_cmake \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DGFLAGS_NAMESPACE=gflags \
    -DCMAKE_CXX_FLAGS="-fPIC $(MAC_VERSION)" \
    -DCMAKE_INSTALL_PREFIX=../../install && \
  $(CMAKE) --build build_cmake -- -j 4 && \
  $(CMAKE) --build build_cmake --target install

dependencies/sources/gflags-$(GFLAGS_TAG): | dependencies/sources
	git clone --quiet -b v$(GFLAGS_TAG) https://github.com/gflags/gflags.git dependencies/sources/gflags-$(GFLAGS_TAG)

GFLAGS_INC = -I$(UNIX_GFLAGS_DIR)/include
STATIC_GFLAGS_LNK = $(UNIX_GFLAGS_DIR)/lib/libgflags.a
DYNAMIC_GFLAGS_LNK = -L$(UNIX_GFLAGS_DIR)/lib -lgflags

ifeq ($(UNIX_GFLAGS_DIR), $(OR_TOOLS_TOP)/dependencies/install)
DEPENDENCIES_LNK += $(DYNAMIC_GFLAGS_LNK)
OR_TOOLS_LNK += $(DYNAMIC_GFLAGS_LNK)
else
DEPENDENCIES_LNK += $(DYNAMIC_GFLAGS_LNK)
OR_TOOLS_LNK += $(DYNAMIC_GFLAGS_LNK)
endif

############
##  GLOG  ##
############
# This uses glog cmake-based build.
build_glog: dependencies/install/lib/libglog.$L

dependencies/install/lib/libglog.$L: dependencies/install/lib/libgflags.$L dependencies/sources/glog-$(GLOG_TAG) | dependencies/install
	cd dependencies/sources/glog-$(GLOG_TAG) && \
  $(SET_COMPILER) $(CMAKE) -H. -Bbuild_cmake \
    -DCMAKE_PREFIX_PATH="$(OR_TOOLS_TOP)/dependencies/install" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DCMAKE_CXX_FLAGS="-fPIC $(MAC_VERSION)" \
    -DCMAKE_INSTALL_PREFIX=../../install && \
  $(CMAKE) --build build_cmake -- -j 4 && \
  $(CMAKE) --build build_cmake --target install

dependencies/sources/glog-$(GLOG_TAG): | dependencies/sources
	git clone --quiet -b v$(GLOG_TAG) https://github.com/google/glog.git dependencies/sources/glog-$(GLOG_TAG)

GLOG_INC = -I$(UNIX_GLOG_DIR)/include
STATIC_GLOG_LNK = $(UNIX_GLOG_DIR)/lib/libglog.a
DYNAMIC_GLOG_LNK = -L$(UNIX_GLOG_DIR)/lib -lglog

ifeq ($(UNIX_GLOG_DIR), $(OR_TOOLS_TOP)/dependencies/install)
DEPENDENCIES_LNK += $(DYNAMIC_GLOG_LNK)
OR_TOOLS_LNK += $(DYNAMIC_GLOG_LNK)
else
DEPENDENCIES_LNK += $(DYNAMIC_GLOG_LNK)
OR_TOOLS_LNK += $(DYNAMIC_GLOG_LNK)
endif

################
##  Protobuf  ##
################
# This uses Protobuf cmake-based build.
build_protobuf: dependencies/install/lib/libprotobuf.$L

dependencies/install/lib/libprotobuf.$L: dependencies/install/lib/libglog.$L dependencies/sources/protobuf-$(PROTOBUF_TAG) | dependencies/install
	cd dependencies/sources/protobuf-$(PROTOBUF_TAG) && \
  $(SET_COMPILER) $(CMAKE) -Hcmake -Bbuild_cmake \
    -DCMAKE_PREFIX_PATH="$(OR_TOOLS_TOP)/dependencies/install" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_EXAMPLES=OFF \
    -DCMAKE_CXX_FLAGS="-fPIC $(MAC_VERSION)" \
    -DCMAKE_INSTALL_PREFIX=../../install && \
  $(CMAKE) --build build_cmake -- -j 4 && \
  $(CMAKE) --build build_cmake --target install

dependencies/sources/protobuf-$(PROTOBUF_TAG): patches/protobuf.patch | dependencies/sources
	git clone --quiet -b v$(PROTOBUF_TAG) https://github.com/google/protobuf.git dependencies/sources/protobuf-$(PROTOBUF_TAG)
	cd dependencies/sources/protobuf-$(PROTOBUF_TAG) && \
    git apply $(OR_TOOLS_TOP)/patches/protobuf.patch

# Install Java protobuf
dependencies/install/lib/protobuf.jar: build_protobuf
	cd dependencies/sources/protobuf-$(PROTOBUF_TAG)/java && \
	  ../../../install/bin/protoc --java_out=core/src/main/java -I../src \
	  ../src/google/protobuf/descriptor.proto
	cd dependencies/sources/protobuf-$(PROTOBUF_TAG)/java/core/src/main/java && \
		$(JAVAC_BIN) com/google/protobuf/*java
	cd dependencies/sources/protobuf-$(PROTOBUF_TAG)/java/core/src/main/java && \
		$(JAR_BIN) cvf ../../../../../../../install/lib/protobuf.jar com/google/protobuf/*class

# This is needed to find protocol buffers.
PROTOBUF_INC = -I$(UNIX_PROTOBUF_DIR)/include
PROTOBUF_PROTOC_INC = $(PROTOBUF_INC)
# libprotobuf.a goes in a different subdirectory depending on the distribution
# and architecture, eg. "lib/" or "lib64/" for Fedora and Centos,
# "lib/x86_64-linux-gnu/" for Ubuntu (all on 64 bits), etc. So we wildcard it.
STATIC_PROTOBUF_LNK = $(wildcard $(UNIX_PROTOBUF_DIR)/lib*/libprotobuf.a \
                          $(UNIX_PROTOBUF_DIR)/lib/*/libprotobuf.a)
_PROTOBUF_LIB_DIR = $(wildcard $(UNIX_PROTOBUF_DIR)/lib*/libprotobuf.$L \
                          $(UNIX_PROTOBUF_DIR)/lib/*/libprotobuf.$L)
DYNAMIC_PROTOBUF_LNK = -L$(dir $(_PROTOBUF_LIB_DIR)) -lprotobuf

ifeq ($(UNIX_PROTOBUF_DIR), $(OR_TOOLS_TOP)/dependencies/install)
DEPENDENCIES_LNK += $(DYNAMIC_PROTOBUF_LNK)
OR_TOOLS_LNK += $(DYNAMIC_PROTOBUF_LNK)
else
DEPENDENCIES_LNK += $(DYNAMIC_PROTOBUF_LNK)
OR_TOOLS_LNK += $(DYNAMIC_PROTOBUF_LNK)
endif
# Define Protoc
ifeq ($(PLATFORM),LINUX)
 PROTOC = \
LD_LIBRARY_PATH="$(UNIX_PROTOBUF_DIR)/lib":$(LD_LIBRARY_PATH) $(PROTOC_BINARY)
else
 PROTOC = \
DYLD_LIBRARY_PATH="$(UNIX_PROTOBUF_DIR)/lib":$(DYLD_LIBRARY_PATH) $(PROTOC_BINARY)
endif

###################
##  COIN-OR-CBC  ##
###################
build_cbc: dependencies/install/lib/libCbc.$L

dependencies/install/lib/libCbc.$L: dependencies/install/lib/libCgl.$L dependencies/sources/Cbc-$(CBC_TAG) | dependencies/install/lib
	cd dependencies/sources/Cbc-$(CBC_TAG) && \
  $(SET_COMPILER) ./configure \
    --prefix=$(OR_ROOT_FULL)/dependencies/install \
    --disable-debug \
    --without-blas \
    --without-lapack \
    --without-glpk \
    --with-pic \
    --enable-dependency-linking \
    --enable-cbc-parallel \
    ADD_CXXFLAGS="-w $(MAC_VERSION)" \
    LDFLAGS="$(DYNAMIC_LDFLAGS)" && \
  $(SET_COMPILER) make -j 4 && \
  $(SET_COMPILER) make install

dependencies/sources/Cbc-$(CBC_TAG): | dependencies/sources
	git clone --quiet -b releases/$(CBC_TAG) https://github.com/coin-or/Cbc.git dependencies/sources/Cbc-$(CBC_TAG)

# This is needed to find CBC include files.
CBC_COIN_DIR = $(firstword $(wildcard $(UNIX_CBC_DIR)/include/cbc/coin \
                                      $(UNIX_CBC_DIR)/include/coin))
CBC_INC = -I$(UNIX_CBC_DIR)/include -I$(CBC_COIN_DIR) -DUSE_CBC
CBC_SWIG = $(CBC_INC)
ifneq ($(wildcard $(UNIX_CBC_DIR)/lib/coin),)
 UNIX_CBC_COIN = /coin
endif
STATIC_CBC_LNK = $(UNIX_CBC_DIR)/lib$(UNIX_CBC_COIN)/libCbcSolver.a \
          $(UNIX_CBC_DIR)/lib$(UNIX_CBC_COIN)/libOsiCbc.a \
          $(UNIX_CBC_DIR)/lib$(UNIX_CBC_COIN)/libCbc.a
DYNAMIC_CBC_LNK = -L$(UNIX_CBC_DIR)/lib$(UNIX_CBC_COIN) -lCbcSolver -lCbc -lOsiCbc

###################
##  COIN-OR-CGL  ##
###################
build_cgl: dependencies/install/lib/libCgl.$L

dependencies/install/lib/libCgl.$L: dependencies/install/lib/libClp.$L dependencies/sources/Cgl-$(CGL_TAG) | dependencies/install/lib
	cd dependencies/sources/Cgl-$(CGL_TAG) && \
  $(SET_COMPILER) ./configure \
    --prefix=$(OR_ROOT_FULL)/dependencies/install \
    --disable-debug \
    --without-blas \
    --without-lapack \
    --without-glpk \
    --with-pic \
    --enable-dependency-linking \
    ADD_CXXFLAGS="-w $(MAC_VERSION)" \
    LDFLAGS="$(DYNAMIC_LDFLAGS)" && \
  $(SET_COMPILER) make -j 4 && \
  $(SET_COMPILER) make install

dependencies/sources/Cgl-$(CGL_TAG): | dependencies/sources
	git clone --quiet -b releases/$(CGL_TAG) https://github.com/coin-or/Cgl.git dependencies/sources/Cgl-$(CGL_TAG)

# This is needed to find CGL include files.
CGL_COIN_DIR = $(firstword $(wildcard $(UNIX_CGL_DIR)/include/cgl/coin \
                                      $(UNIX_CGL_DIR)/include/coin))
CGL_INC = -I$(UNIX_CGL_DIR)/include -I$(CGL_COIN_DIR)
CGL_SWIG = $(CGL_INC)
ifneq ($(wildcard $(UNIX_CGL_DIR)/lib/coin),)
 UNIX_CGL_COIN = /coin
endif
STATIC_CGL_LNK = $(UNIX_CGL_DIR)/lib$(UNIX_CGL_COIN)/libCgl.a
DYNAMIC_CGL_LNK = -L$(UNIX_CGL_DIR)/lib$(UNIX_CGL_COIN) -lCgl

###################
##  COIN-OR-CLP  ##
###################
build_clp: dependencies/install/lib/libClp.$L

dependencies/install/lib/libClp.$L: dependencies/install/lib/libOsi.$L dependencies/sources/Clp-$(CLP_TAG) | dependencies/install/lib
	cd dependencies/sources/Clp-$(CLP_TAG) && \
  $(SET_COMPILER) ./configure \
    --prefix=$(OR_ROOT_FULL)/dependencies/install \
    --disable-debug \
    --without-blas \
    --without-lapack \
    --without-glpk \
    --with-pic \
    --enable-dependency-linking \
    ADD_CXXFLAGS="-w $(MAC_VERSION)" \
    LDFLAGS="$(DYNAMIC_LDFLAGS)" && \
  $(SET_COMPILER) make -j 4 && \
  $(SET_COMPILER) make install

dependencies/sources/Clp-$(CLP_TAG): | dependencies/sources
	git clone --quiet -b releases/$(CLP_TAG) https://github.com/coin-or/Clp.git dependencies/sources/Clp-$(CLP_TAG)

# This is needed to find CLP include files.
CLP_COIN_DIR = $(firstword $(wildcard $(UNIX_CLP_DIR)/include/clp/coin \
                                      $(UNIX_CLP_DIR)/include/coin))
CLP_INC = -I$(UNIX_CLP_DIR)/include -I$(CLP_COIN_DIR) -DUSE_CLP
CLP_SWIG = $(CLP_INC)
ifneq ($(wildcard $(UNIX_CLP_DIR)/lib/coin),)
 UNIX_CLP_COIN = /coin
endif
STATIC_CLP_LNK = $(UNIX_CBC_DIR)/lib$(UNIX_CLP_COIN)/libClpSolver.a \
          $(UNIX_CLP_DIR)/lib$(UNIX_CLP_COIN)/libOsiClp.a \
          $(UNIX_CLP_DIR)/lib$(UNIX_CLP_COIN)/libClp.a
DYNAMIC_CLP_LNK = -L$(UNIX_CLP_DIR)/lib$(UNIX_CLP_COIN) -lClpSolver -lClp -lOsiClp

###################
##  COIN-OR-OSI  ##
###################
build_osi: dependencies/install/lib/libOsi.$L

dependencies/install/lib/libOsi.$L: dependencies/install/lib/libCoinUtils.$L dependencies/sources/Osi-$(OSI_TAG) | dependencies/install/lib
	cd dependencies/sources/Osi-$(OSI_TAG) && \
  $(SET_COMPILER) ./configure \
    --prefix=$(OR_ROOT_FULL)/dependencies/install \
    --disable-debug \
    --without-blas \
    --without-lapack \
    --without-glpk \
    --with-pic \
    --with-coinutils \
    --enable-dependency-linking \
    ADD_CXXFLAGS="-w $(MAC_VERSION)" \
    LDFLAGS="$(DYNAMIC_LDFLAGS)" && \
  $(SET_COMPILER) make -j 4 && \
  $(SET_COMPILER) make install

dependencies/sources/Osi-$(OSI_TAG): | dependencies/sources
	git clone --quiet -b releases/$(OSI_TAG) https://github.com/coin-or/Osi.git dependencies/sources/Osi-$(OSI_TAG)

# This is needed to find OSI include files.
OSI_COIN_DIR = $(firstword $(wildcard $(UNIX_OSI_DIR)/include/osi/coin \
                                      $(UNIX_OSI_DIR)/include/coin))
OSI_INC = -I$(UNIX_OSI_DIR)/include -I$(OSI_COIN_DIR)
OSI_SWIG = $(OSI_INC)
ifneq ($(wildcard $(UNIX_OSI_DIR)/lib/coin),)
 UNIX_OSI_COIN = /coin
endif
STATIC_OSI_LNK = $(UNIX_OSI_DIR)/lib$(UNIX_OSI_COIN)/libOsi.a
DYNAMIC_OSI_LNK = -L$(UNIX_OSI_DIR)/lib$(UNIX_OSI_COIN) -lOsi

#########################
##  COIN-OR-COINUTILS  ##
#########################
build_coinutils: dependencies/install/lib/libCoinUtils.$L

dependencies/install/lib/libCoinUtils.$L: dependencies/sources/CoinUtils-$(COINUTILS_TAG) | dependencies/install/lib
	cd dependencies/sources/CoinUtils-$(COINUTILS_TAG) && \
  $(SET_COMPILER) ./configure \
    --prefix=$(OR_ROOT_FULL)/dependencies/install \
    --disable-debug \
    --without-blas \
    --without-lapack \
    --without-glpk \
    --with-pic \
    --enable-dependency-linking \
    ADD_CXXFLAGS="-w $(MAC_VERSION)" \
    LDFLAGS="$(DYNAMIC_LDFLAGS)" && \
  $(SET_COMPILER) make -j 4 && \
  $(SET_COMPILER) make install

dependencies/sources/CoinUtils-$(COINUTILS_TAG): | dependencies/sources
	git clone --quiet -b releases/$(COINUTILS_TAG) https://github.com/coin-or/CoinUtils.git dependencies/sources/CoinUtils-$(COINUTILS_TAG)

# This is needed to find COINUTILS include files.
COINUTILS_COIN_DIR = $(firstword $(wildcard $(UNIX_COINUTILS_DIR)/include/coinutils/coin \
                                      $(UNIX_COINUTILS_DIR)/include/coin))
COINUTILS_INC = -I$(UNIX_COINUTILS_DIR)/include -I$(COINUTILS_COIN_DIR)
COINUTILS_SWIG = $(COINUTILS_INC)
ifneq ($(wildcard $(UNIX_COINUTILS_DIR)/lib/coin),)
 UNIX_COINUTILS_COIN = /coin
endif
STATIC_COINUTILS_LNK = $(UNIX_COINUTILS_DIR)/lib$(UNIX_COINUTILS_COIN)/libCoinUtils.a
DYNAMIC_COINUTILS_LNK = -L$(UNIX_COINUTILS_DIR)/lib$(UNIX_COINUTILS_COIN) -lCoinUtils

############
##  COIN  ##
############
# Agregate all previous coin packages
COIN_INC = \
  $(COINUTILS_INC) \
  $(OSI_INC) \
  $(CLP_INC) \
  $(CGL_INC) \
  $(CBC_INC)
COIN_SWIG = \
  $(COINUTILS_SWIG) \
  $(OSI_SWIG) \
  $(CLP_SWIG) \
  $(CGL_SWIG) \
  $(CBC_SWIG)
STATIC_COIN_LNK = \
  $(STATIC_CBC_LNK) \
  $(STATIC_CGL_LNK) \
  $(STATIC_CLP_LNK) \
  $(STATIC_OSI_LNK) \
  $(STATIC_COINUTILS_LNK)
DYNAMIC_COIN_LNK = \
  $(DYNAMIC_CBC_LNK) \
  $(DYNAMIC_CGL_LNK) \
  $(DYNAMIC_CLP_LNK) \
  $(DYNAMIC_OSI_LNK) \
  $(DYNAMIC_COINUTILS_LNK)

ifeq ($(UNIX_CBC_DIR), $(OR_TOOLS_TOP)/dependencies/install)
DEPENDENCIES_LNK += $(DYNAMIC_COIN_LNK)
OR_TOOLS_LNK += $(DYNAMIC_COIN_LNK)
else
DEPENDENCIES_LNK += $(DYNAMIC_COIN_LNK)
OR_TOOLS_LNK += $(DYNAMIC_COIN_LNK)
endif

############
##  SWIG  ##
############
# Swig is only needed when building .Net, Java or Python wrapper
SWIG_BINARY = $(shell $(WHICH) $(UNIX_SWIG_BINARY))
#$(error "Can't find $(UNIX_SWIG_BINARY). Please verify UNIX_SWIG_BINARY")

##################################
##  USE DYNAMIC DEPENDENCIES ?  ##
##################################

############################################
##  Install Patchelf on linux platforms.  ##
############################################
# Detect if patchelf is needed
ifeq ($(PLATFORM), LINUX)
 PATCHELF=dependencies/install/bin/patchelf
endif

dependencies/install/bin/patchelf: dependencies/sources/patchelf-$(PATCHELF_TAG)/Makefile
	cd dependencies/sources/patchelf-$(PATCHELF_TAG) && make && make install

dependencies/sources/patchelf-$(PATCHELF_TAG)/Makefile: dependencies/sources/patchelf-$(PATCHELF_TAG)/configure
	cd dependencies/sources/patchelf-$(PATCHELF_TAG) && ./configure --prefix=$(OR_ROOT_FULL)/dependencies/install

dependencies/sources/patchelf-$(PATCHELF_TAG)/configure:
	git clone --quiet -b $(PATCHELF_TAG) https://github.com/NixOS/patchelf.git dependencies/sources/patchelf-$(PATCHELF_TAG)
	cd dependencies/sources/patchelf-$(PATCHELF_TAG) && ./bootstrap.sh

.PHONY: clean_third_party # Clean everything. Remember to also delete archived dependencies, i.e. in the event of download failure, etc.
clean_third_party:
	-$(DEL) Makefile.local
	-$(DELREC) dependencies/archives/Cbc*
	-$(DELREC) dependencies/archives/Cgl*
	-$(DELREC) dependencies/archives/Clp*
	-$(DELREC) dependencies/archives/Osi*
	-$(DELREC) dependencies/archives/CoinUtils*
	-$(DELREC) dependencies/archives
	-$(DELREC) dependencies/sources/gflags*
	-$(DELREC) dependencies/sources/glog*
	-$(DELREC) dependencies/sources/protobuf*
	-$(DELREC) dependencies/sources/google*
	-$(DELREC) dependencies/sources/Cbc*
	-$(DELREC) dependencies/sources/Cgl*
	-$(DELREC) dependencies/sources/Clp*
	-$(DELREC) dependencies/sources/Osi*
	-$(DELREC) dependencies/sources/CoinUtils*
	-$(DELREC) dependencies/sources/swig*
	-$(DELREC) dependencies/sources/mono*
	-$(DELREC) dependencies/sources/glpk*
	-$(DELREC) dependencies/sources/pcre*
	-$(DELREC) dependencies/sources/sparsehash*
	-$(DELREC) dependencies/sources/libtool*
	-$(DELREC) dependencies/sources/autoconf*
	-$(DELREC) dependencies/sources/automake*
	-$(DELREC) dependencies/sources/bison*
	-$(DELREC) dependencies/sources/flex*
	-$(DELREC) dependencies/sources/help2man*
	-$(DELREC) dependencies/sources/patchelf*
	-$(DELREC) dependencies/install

# Create Makefile.local
.PHONY: makefile_third_party
makefile_third_party: Makefile.local

Makefile.local: makefiles/Makefile.third_party.unix.mk
	-$(DEL) Makefile.local
	@echo Generating Makefile.local
	@echo "# Define UNIX_SWIG_BINARY to use a custom version." >> Makefile.local
	@echo "#   e.g. UNIX_SWIG_BINARY = /opt/swig-x.y.z/bin/swig" >> Makefile.local
	@echo JAVA_HOME = $(JAVA_HOME)>> Makefile.local
	@echo UNIX_PYTHON_VER = $(DETECTED_PYTHON_VERSION)>> Makefile.local
	@echo PATH_TO_CSHARP_COMPILER = $(DETECTED_MCS_BINARY)>> Makefile.local
	@echo DOTNET_INSTALL_PATH = $(DOTNET_INSTALL_PATH)>> Makefile.local
	@echo CLR_KEYFILE = bin/or-tools.snk>> Makefile.local
	@echo >> Makefile.local
	@echo "## OPTIONAL DEPENDENCIES ##" >> Makefile.local
	@echo "# Define UNIX_CPLEX_DIR to use CPLEX" >> Makefile.local
	@echo >> Makefile.local
	@echo "# Define UNIX_GLPK_DIR to point to a compiled version of GLPK to use it" >> Makefile.local
	@echo "#   e.g. UNIX_GLPK_DIR = /opt/glpk-x.y.z" >> Makefile.local
	@echo >> Makefile.local
	@echo "# Define UNIX_GUROBI_DIR and GUROBI_LIB_VERSION to use Gurobi" >> Makefile.local
	@echo >> Makefile.local
	@echo "# Define UNIX_SCIP_DIR to point to a compiled version of SCIP to use it ">> Makefile.local
	@echo "#   e.g. UNIX_SCIP_DIR = <path>/scipoptsuite-4.0.1/scip" >> Makefile.local
	@echo "#   On Mac OS X, compile scip with: " >> Makefile.local
	@echo "#     make GMP=false READLINE=false TPI=tny" >> Makefile.local
	@echo "#   On Linux, compile scip with: " >> Makefile.local
	@echo "#     make GMP=false READLINE=false TPI=tny USRCFLAGS=-fPIC USRCXXFLAGS=-fPIC USRCPPFLAGS=-fPIC" >> Makefile.local
	@echo >> Makefile.local
	@echo "## REQUIRED DEPENDENCIES ##" >> Makefile.local
	@echo "# By default they will be automatically built -> nothing to define" >> Makefile.local
	@echo "# Define UNIX_GFLAGS_DIR to depend on external Gflags dynamic library" >> Makefile.local
	@echo "#   e.g. UNIX_GFLAGS_DIR = /opt/gflags-x.y.z" >> Makefile.local
	@echo >> Makefile.local
	@echo "# Define UNIX_GLOG_DIR to depend on external Glog dynamic library" >> Makefile.local
	@echo "#   e.g. UNIX_GLOG_DIR = /opt/glog-x.y.z" >> Makefile.local
	@echo >> Makefile.local
	@echo "# Define UNIX_PROTOBUF_DIR to depend on external Protobuf dynamic library" >> Makefile.local
	@echo "#   e.g. UNIX_PROTOBUF_DIR = /opt/protobuf-x.y.z" >> Makefile.local
	@echo "# Define UNIX_PROTOC_BINARY to use a custom version." >> Makefile.local
	@echo "#   e.g. UNIX_PROTOC_BINARY = /opt/protoc-x.y.z/bin/protoc" >> Makefile.local
	@echo "#   (default: UNIX_PROTOBUF_DIR/bin/protoc)" >> Makefile.local
	@echo >> Makefile.local
	@echo "# Define UNIX_CBC_DIR to depend on external CBC dynamic library" >> Makefile.local
	@echo "#   e.g. UNIX_CBC_DIR = /opt/cbc-x.y.z" >> Makefile.local
	@echo "#   If you use a splitted version of CBC you can also define:" >> Makefile.local
	@echo "#     UNIX_CLP_DIR, UNIX_CGL_DIR, UNIX_OSI_DIR, UNIX_COINUTILS_DIR" >> Makefile.local
	@echo "#   note: by default they all point to UNIX_CBC_DIR" >> Makefile.local
	@echo >> Makefile.local
	@echo "# note: You don't need to run \"make third_party\" if you only use external dependencies" >> Makefile.local
	@echo "# i.e. you define all UNIX_GFLAGS_DIR, UNIX_GLOG_DIR, UNIX_PROTOBUF_DIR and UNIX_CBC_DIR" >> Makefile.local

.PHONY: detect_third_party # Show variables used to find third party
detect_third_party:
	@echo Relevant info on third party:
	@echo UNIX_GFLAGS_DIR = $(UNIX_GFLAGS_DIR)
	@echo GFLAGS_INC = $(GFLAGS_INC)
	@echo GFLAGS_LNK = $(GFLAGS_LNK)
	@echo UNIX_GLOG_DIR = $(UNIX_GLOG_DIR)
	@echo GLOG_INC = $(GLOG_INC)
	@echo GLOG_LNK = $(GLOG_LNK)
	@echo UNIX_PROTOBUF_DIR = $(UNIX_PROTOBUF_DIR)
	@echo PROTOBUF_INC = $(PROTOBUF_INC)
	@echo PROTOBUF_LNK = $(PROTOBUF_LNK)
	@echo UNIX_CBC_DIR = $(UNIX_CBC_DIR)
	@echo CBC_INC = $(CBC_INC)
	@echo CBC_LNK = $(CBC_LNK)
	@echo UNIX_CLP_DIR = $(UNIX_CLP_DIR)
	@echo CLP_INC = $(CLP_INC)
	@echo CLP_LNK = $(CLP_LNK)
	@echo UNIX_CGL_DIR = $(UNIX_CGL_DIR)
	@echo CGL_INC = $(CGL_INC)
	@echo CGL_LNK = $(CGL_LNK)
	@echo UNIX_OSI_DIR = $(UNIX_OSI_DIR)
	@echo OSI_INC = $(OSI_INC)
	@echo OSI_LNK = $(OSI_LNK)
	@echo UNIX_COINUTILS_DIR = $(UNIX_COINUTILS_DIR)
	@echo COINUTILS_INC = $(COINUTILS_INC)
	@echo COINUTILS_LNK = $(COINUTILS_LNK)
ifdef UNIX_GLPK_DIR
	@echo UNIX_GLPK_DIR = $(UNIX_GLPK_DIR)
	@echo GLPK_INC = $(GLPK_INC)
	@echo GLPK_LNK = $(GLPK_LNK)
endif
ifdef UNIX_SCIP_DIR
	@echo UNIX_SCIP_DIR = $(UNIX_SCIP_DIR)
	@echo SCIP_INC = $(SCIP_INC)
	@echo SCIP_LNK = $(SCIP_LNK)
endif
ifdef UNIX_CPLEX_DIR
	@echo UNIX_CPLEX_DIR = $(UNIX_CPLEX_DIR)
	@echo CPLEX_INC = $(CPLEX_INC)
	@echo CPLEX_LNK = $(CPLEX_LNK)
endif
ifdef UNIX_GUROBI_DIR
	@echo UNIX_GUROBI_DIR = $(UNIX_GUROBI_DIR)
	@echo GUROBI_INC = $(GUROBI_INC)
	@echo GUROBI_LNK = $(GUROBI_LNK)
endif
	@echo
