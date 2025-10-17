#include <iostream>
#include <cstdint>
#include <dlfcn.h>
#include <string>

// Function pointer type for the cfunc wrapper (C signature)
typedef int64_t (*numba_cfunc_t)(int64_t a, int64_t b);

int main(int argc, char** argv) {
    std::cout << "=== NRT Test with New Build Structure ===" << std::endl;
    
    // Check command line arguments
    if (argc != 3) {
        std::cerr << "Usage: " << argv[0] << " <so_file_path> <function_name>" << std::endl;
        std::cerr << "Example: " << argv[0] << " ./numba_func.so _ZN8__main__3addB2v1B54c8tJTIeFIjxB2IKSgI4CrvQClUYkACQB1EiFSRTB9CAlIrCIJgA_3dExx" << std::endl;
        return 1;
    }
    
    std::string so_file_path = argv[1];
    std::string function_name = argv[2];
    std::cout << "Loading .so file: " << so_file_path << std::endl;
    std::cout << "Looking for function: " << function_name << std::endl;
    
    // Load the Numba shared library (this will initialize NRT automatically)
    std::cout << "Loading Numba shared library..." << std::endl;
    void* handle = dlopen(so_file_path.c_str(), RTLD_NOW | RTLD_GLOBAL);
    if (!handle) {
        std::cerr << "Error loading shared library: " << dlerror() << std::endl;
        return 1;
    }
    
    std::cout << "Calling Numba cfunc wrapper..." << std::endl;
    
    // Get function pointer using dlsym from the loaded shared library
    numba_cfunc_t func = (numba_cfunc_t)dlsym(handle, function_name.c_str());
    if (!func) {
        std::cerr << "Error: Function '" << function_name << "' not found: " << dlerror() << std::endl;
        dlclose(handle);
        return 1;
    }
    
    // Call the cfunc wrapper directly
    int64_t result = func(21, 21);
    std::cout << "Success! Result: " << result << std::endl;
    
    // Cleanup - close the shared library (this will automatically shutdown NRT)
    std::cout << "Closing shared library..." << std::endl;
    dlclose(handle);
    
    std::cout << "=== Test Complete ===" << std::endl;
    return 0;
}