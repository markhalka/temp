#include <iostream>
#include <cstdint>

// Include NRT headers from our new build structure
extern "C" {
    #include "nrt.h"
    #include "nrt_external.h"
    
    // Declare the numba function directly (no dynamic loading)
    // This will be linked at compile time
    int _ZN8__main__3addB2v1B54c8tJTIeFIjxB2IKSgI4CrvQClUYkACQB1EiFSRTB9CAlIrCIJgA_3dExx(
        int64_t* result_ptr,    // Pointer to store result
        void** error_ptr,       // Pointer to store error info
        int64_t a,              // First argument
        int64_t b               // Second argument
    );
}

int main(int argc, char** argv) {
    std::cout << "=== NRT Test with New Build Structure ===" << std::endl;
    
    // Initialize NRT memory system before using any Numba functions
    std::cout << "Initializing NRT memory system..." << std::endl;
    NRT_MemSys_init();
    
    std::cout << "Calling Numba function with NRT support..." << std::endl;
    
    int64_t result = 0;
    void* error = nullptr;
    
    // Call the function directly with correct calling convention
    int status = _ZN8__main__3addB2v1B54c8tJTIeFIjxB2IKSgI4CrvQClUYkACQB1EiFSRTB9CAlIrCIJgA_3dExx(
        &result,    // Pass pointer to result
        &error,     // Pass pointer to error
        21,         // First argument
        21          // Second argument  
    );
    
    if (status == 0) {
        std::cout << "Success! Result: " << result << std::endl;
    } else {
        std::cout << "Error occurred, status: " << status << std::endl;
        if (error != nullptr) {
            std::cout << "Error pointer: " << error << std::endl;
        }
    }
    
    // Shutdown NRT memory system
    std::cout << "Shutting down NRT memory system..." << std::endl;
    NRT_MemSys_shutdown();
    
    std::cout << "=== Test Complete ===" << std::endl;
    return 0;
}