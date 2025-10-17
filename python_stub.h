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
