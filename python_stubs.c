/*
 * Minimal Python stubs for standalone NRT compilation.
 * This file provides empty implementations of Python API functions
 * that might be referenced but not used in standalone mode.
 */

#include "Python.h"

/* Empty implementations of Python API functions that might be referenced */
void Py_Initialize(void) {
    /* Empty - not needed in standalone mode */
}

void Py_Finalize(void) {
    /* Empty - not needed in standalone mode */
}

int Py_IsInitialized(void) {
    return 0; /* Not initialized in standalone mode */
}

/* Additional stubs for Numba runtime functions */
void numba_gil_ensure(void) {
    /* Empty - GIL not needed in standalone mode */
}

void numba_gil_release(void) {
    /* Empty - GIL not needed in standalone mode */
}

void PyErr_Clear(void) {
    /* Empty - error handling not needed in standalone mode */
}

PyObject* PyBytes_FromStringAndSize(const char* str, Py_ssize_t size) {
    return NULL; /* Not implemented in standalone mode */
}

void numba_runtime_build_excinfo_struct(void) {
    /* Empty - exception handling not needed in standalone mode */
}

void numba_do_raise(void) {
    /* Empty - exception handling not needed in standalone mode */
}

PyObject* PyUnicode_FromString(const char* str) {
    return NULL; /* Not implemented in standalone mode */
}

void PyErr_WriteUnraisable(PyObject* obj) {
    /* Empty - error handling not needed in standalone mode */
}

void Py_DecRef(PyObject* obj) {
    /* Empty - reference counting not needed in standalone mode */
}

void numba_unpickle(void) {
    /* Empty - unpickling not needed in standalone mode */
}

PyObject* PyExc_RuntimeError = NULL; /* Exception object */

void PyErr_SetString(PyObject* exc, const char* str) {
    /* Empty - error handling not needed in standalone mode */
}
