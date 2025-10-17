#include <iostream>
#include <cstdint>

// Include NRT headers for initialization  
extern "C" {
    void NRT_MemSys_init(void);
    void NRT_MemSys_shutdown(void);
    
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
    // Initialize NRT memory system before using any Numba functions
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
    }
    
    // Shutdown NRT memory system
    NRT_MemSys_shutdown();
    return 0;
}