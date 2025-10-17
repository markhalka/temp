#include <iostream>
// size_t
#include <cstddef>

// Include NRT headers
extern "C" {
    #include "nrt.h"
    #include "nrt_external.h"
}

// Function to initialize NRT - this will be called when the .so is loaded
extern "C" void init_nrt() {
    std::cout << "Initializing NRT memory system from shared library..." << std::endl;
    NRT_MemSys_init();
}

// Function to shutdown NRT
extern "C" void shutdown_nrt() {
    std::cout << "Shutting down NRT memory system from shared library..." << std::endl;
    NRT_MemSys_shutdown();
}

// Export NRT functions that Numba code needs
extern "C" {
    // Force export of NRT functions
    void* NRT_MemInfo_alloc_dtor_wrapper(size_t size, void (*dtor)(void*, size_t, void*)) {
        return NRT_MemInfo_alloc_dtor(size, dtor);
    }
    
    void NRT_MemInfo_call_dtor_wrapper(NRT_MemInfo* meminfo) {
        NRT_MemInfo_call_dtor(meminfo);
    }
    
    void NRT_Free_wrapper(void* ptr) {
        NRT_Free(ptr);
    }
}

// Constructor - automatically called when .so is loaded
__attribute__((constructor))
void nrt_constructor() {
    std::cout << "NRT initializer .so loaded - calling init_nrt()" << std::endl;
    init_nrt();
}

// Destructor - automatically called when .so is unloaded
__attribute__((destructor))
void nrt_destructor() {
    std::cout << "NRT initializer .so unloaded - calling shutdown_nrt()" << std::endl;
    shutdown_nrt();
}
