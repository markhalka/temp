#!/bin/bash

# Build script to create NRT (Numba Runtime) shared library

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building NRT (Numba Runtime) Library...${NC}"

# Directories
NRT_SRC_DIR="./numba/numba/core/runtime"
CEXT_SRC_DIR="./numba/numba/cext"
NUMBA_SRC_DIR="./numba/numba"
BUILD_DIR="./nrt_build"
INSTALL_DIR="./nrt_lib"

# Create build directory
mkdir -p ${BUILD_DIR}
mkdir -p ${INSTALL_DIR}/include
mkdir -p ${INSTALL_DIR}/lib

# Copy headers to install directory
echo -e "${YELLOW}Copying headers...${NC}"
cp ${NRT_SRC_DIR}/nrt.h ${INSTALL_DIR}/include/
cp ${NRT_SRC_DIR}/nrt_external.h ${INSTALL_DIR}/include/
cp ${CEXT_SRC_DIR}/cext.h ${INSTALL_DIR}/include/
cp ${CEXT_SRC_DIR}/listobject.h ${INSTALL_DIR}/include/
cp ${CEXT_SRC_DIR}/dictobject.h ${INSTALL_DIR}/include/
cp ./numba/numba/_numba_common.h ${INSTALL_DIR}/include/

# Create a comprehensive Python.h stub for compilation
cat > ${INSTALL_DIR}/include/Python.h << 'EOF'
#ifndef PYTHON_H
#define PYTHON_H

#include <stddef.h>
#include <stdint.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

// Basic Python types
typedef struct _object PyObject;
typedef long Py_ssize_t;
typedef unsigned long Py_hash_t;
typedef int Py_intptr_t;

// Python constants  
#define Py_ssize_t_MAX ((Py_ssize_t)(((size_t)-1) >> 1))
#define Py_ssize_t_MIN (-Py_ssize_t_MAX - 1)
#define PY_SSIZE_T_MAX Py_ssize_t_MAX
#define PY_SSIZE_T_MIN Py_ssize_t_MIN

// Python GIL state
typedef enum { PyGILState_LOCKED, PyGILState_UNLOCKED } PyGILState_STATE;

// Memory allocation macros (redirect to standard malloc/free)
#define PyMem_Malloc malloc
#define PyMem_Free free
#define PyMem_Realloc realloc

// Error handling stubs
#define PyErr_NoMemory() ((PyObject*)NULL)
#define PyErr_BadInternalCall() ((void)0)

// Object creation stubs
#define Py_INCREF(op) ((void)0)
#define Py_DECREF(op) ((void)0)
#define Py_XINCREF(op) ((void)0) 
#define Py_XDECREF(op) ((void)0)

// Assert macro - for standalone mode, just abort on assertion failure
#define assert(expr) ((expr) ? (void)0 : (fprintf(stderr, "Assertion failed: %s, file %s, line %d\\n", #expr, __FILE__, __LINE__), abort()))

#endif /* PYTHON_H */
EOF

# Compile NRT source files
echo -e "${YELLOW}Compiling NRT sources...${NC}"

# Compile nrt.cpp
g++ -c -fPIC -g -O0 -std=c++11 \
    -I${NRT_SRC_DIR} \
    -I${CEXT_SRC_DIR} \
    -I${INSTALL_DIR}/include \
    -fvisibility=default \
    ${NRT_SRC_DIR}/nrt.cpp \
    -o ${BUILD_DIR}/nrt.o

# Compile listobject.c
echo -e "${YELLOW}Compiling listobject.c...${NC}"
gcc -c -fPIC -g -O0 -w -Wno-builtin-declaration-mismatch \
    -I${CEXT_SRC_DIR} \
    -I${INSTALL_DIR}/include \
    -DVISIBILITY_HIDDEN='__attribute__((visibility("default")))' \
    -DVISIBILITY_GLOBAL='__attribute__((visibility("default")))' \
    ${CEXT_SRC_DIR}/listobject.c \
    -o ${BUILD_DIR}/listobject.o

# Compile dictobject.c
echo -e "${YELLOW}Compiling dictobject.c...${NC}"
gcc -c -fPIC -g -O0 -w -Wno-builtin-declaration-mismatch \
    -I${CEXT_SRC_DIR} \
    -I${INSTALL_DIR}/include \
    -DVISIBILITY_HIDDEN='__attribute__((visibility("default")))' \
    -DVISIBILITY_GLOBAL='__attribute__((visibility("default")))' \
    ${CEXT_SRC_DIR}/dictobject.c \
    -o ${BUILD_DIR}/dictobject.o

# Compile utils.c
echo -e "${YELLOW}Compiling utils.c...${NC}"
gcc -c -fPIC -g -O0 \
    -I${CEXT_SRC_DIR} \
    -I${INSTALL_DIR}/include \
    ${CEXT_SRC_DIR}/utils.c \
    -o ${BUILD_DIR}/utils.o

# Compile Python stubs
echo -e "${YELLOW}Compiling Python stubs...${NC}"
gcc -c -fPIC -g -O0 \
    -I${INSTALL_DIR}/include \
    python_stubs.c \
    -o ${BUILD_DIR}/python_stubs.o

# Create shared library
echo -e "${YELLOW}Creating shared library...${NC}"
g++ -shared -fPIC -g -O0 -Wl,-soname,libnrt.so.1 \
    -Wl,--export-dynamic \
    ${BUILD_DIR}/nrt.o \
    ${BUILD_DIR}/listobject.o \
    ${BUILD_DIR}/dictobject.o \
    ${BUILD_DIR}/utils.o \
    ${BUILD_DIR}/python_stubs.o \
    -o ${INSTALL_DIR}/lib/libnrt.so.1.0.0

# Create symlinks
cd ${INSTALL_DIR}/lib
ln -sf libnrt.so.1.0.0 libnrt.so.1
ln -sf libnrt.so.1 libnrt.so
cd - > /dev/null

# Create static library as well
echo -e "${YELLOW}Creating static library...${NC}"
ar rcs ${INSTALL_DIR}/lib/libnrt.a \
    ${BUILD_DIR}/nrt.o \
    ${BUILD_DIR}/listobject.o \
    ${BUILD_DIR}/dictobject.o \
    ${BUILD_DIR}/utils.o \
    ${BUILD_DIR}/python_stubs.o

# Create pkg-config file
echo -e "${YELLOW}Creating pkg-config file...${NC}"
mkdir -p ${INSTALL_DIR}/lib/pkgconfig
cat > ${INSTALL_DIR}/lib/pkgconfig/nrt.pc << EOF
prefix=$(realpath ${INSTALL_DIR})
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: nrt
Description: Numba Runtime Library
Version: 1.0.0
Libs: -L\${libdir} -lnrt
Cflags: -I\${includedir}
EOF

echo -e "${GREEN}NRT library built successfully!${NC}"
echo -e "${GREEN}Shared library: ${INSTALL_DIR}/lib/libnrt.so${NC}"
echo -e "${GREEN}Static library: ${INSTALL_DIR}/lib/libnrt.a${NC}"
echo -e "${GREEN}Headers: ${INSTALL_DIR}/include/${NC}"

# Display library info
echo -e "${YELLOW}Library information:${NC}"
file ${INSTALL_DIR}/lib/libnrt.so
echo -e "${YELLOW}Exported symbols:${NC}"
nm -D ${INSTALL_DIR}/lib/libnrt.so | grep " T " | head -10
