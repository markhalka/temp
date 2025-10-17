from numba import cfunc, int64
import subprocess
import llvmlite.binding as llvm
import llvmlite.ir as ir
from llvmlite import binding
import tempfile
import os
from numba.typed import List, Dict

@cfunc("int64(int64, int64)", nopython=True, nogil=True, _nrt=True)
def add(a, b):
    a_dict = Dict.empty(key_type=int64, value_type=int64)
    a_dict[1] = a
    a_dict[2] = b
    a_dict[3] = 3
    total = 0
    for k, v in a_dict.items():
        total += v
    return total
    # a_list = List([1, 2, 3])
    # a = [1, 2, 3]
    # l = List([a, a+b, b])
    # return a_dict[1]

def create_module(llvm_ir_str):
    """Create LLVM module from LLVM IR string"""
    # Initialize LLVM
    # llvm.initialize()
    # llvm.initialize_native_target()
    # llvm.initialize_native_asmprinter()
    
    # Parse the LLVM IR string into a module
    mod = llvm.parse_assembly(llvm_ir_str)
    mod.verify()
    return mod

def do_compile(llvm_module, so_name, llvm_ir_str):
    target = llvm.Target.from_default_triple()
    target_machine = target.create_target_machine(reloc="pic")

    with tempfile.NamedTemporaryFile(suffix='.o', delete=False) as obj_file:
        obj_filename = obj_file.name
        
    try:
        # Generate object code
        with open(obj_filename, 'wb') as f:
            f.write(target_machine.emit_object(llvm_module))
        
        # Link to shared library with NRT static library
        nrt_lib_path = os.path.abspath('./nrt_lib/lib')
        nrt_include_path = os.path.abspath('./nrt_lib/include')
        
        subprocess.run([
            'gcc', '-shared', '-fPIC', '-g', '-O0',
            f'-I{nrt_include_path}',
            obj_filename,
            './nrt_lib/lib/libnrt.a',
            '-lstdc++',
            '-o', so_name
        ], check=True)
        
        print(f"Successfully created {so_name}")
        
    finally:
        if os.path.exists(obj_filename):
            os.unlink(obj_filename)

if __name__ == "__main__":
    # Check if NRT library is built
    nrt_lib_path = os.path.abspath('./nrt_lib/lib/libnrt.a')
    if not os.path.exists(nrt_lib_path):
        print("NRT library not found. Please run 'make' first to build the library.")
        print("Available targets:")
        print("  make          - Build shared and static libraries")
        print("  make static   - Build only static library")
        print("  make help     - Show all available targets")
        exit(1)
    
    so_name = './add.so'
    llvm_ir = add.inspect_llvm()
    # print(f"Native function name: {add.native_name}")
    # print(f"Function address: {add.address}")
    try:
        with tempfile.NamedTemporaryFile(suffix='.o', delete=False) as numba_obj:
            numba_obj_name = numba_obj.name
            
        # Generate the numba object file again for linking
        llvm_module_main = create_module(llvm_ir)
        target_main = llvm.Target.from_default_triple()
        target_machine_main = target_main.create_target_machine(reloc="pic")
        
        with open(numba_obj_name, 'wb') as f:
            f.write(target_machine_main.emit_object(llvm_module_main))
        
        # Create static library for the Numba function
        numba_lib_name = './numba_func.a'
        subprocess.run([
            'ar', 'rcs', numba_lib_name, numba_obj_name
        ], check=True)
        
        # Create shared library for the Numba function
        numba_so_name = './numba_func.so'
        nrt_include_path = os.path.abspath('./nrt_lib/include')
        
        subprocess.run([
            'g++', '-shared', '-fPIC', '-g', '-O0', '-std=c++11',
            f'-I{nrt_include_path}',
            numba_obj_name,
            'nrt_init.cpp',
            './nrt_lib/lib/libnrt.a',
            '-lstdc++',
            '-o', numba_so_name
        ], check=True)
        
        # Compile main.cpp (no NRT linking needed - will load from .so)
        subprocess.run([
            'g++', '-std=c++11', '-g', '-O0',
            f'-I{nrt_include_path}',
            'main.cpp',
            '-lstdc++', '-ldl',
            '-o', 'main'
        ], check=True)
        
        # Get the native function name and run main with it
        native_name = add.native_name
        print(f"Native function name: {native_name}")
        
        # Remove the 'cfunc.' prefix to get the actual function name
        actual_function_name = native_name.replace('cfunc.', '')
        print(f"Actual function name: {actual_function_name}")
        print(f"Numba .so file: {numba_so_name}")
        
        subprocess.run(['./main', numba_so_name, actual_function_name])
        
    finally:
        # Clean up
        if os.path.exists(numba_obj_name):
            os.unlink(numba_obj_name)
        if os.path.exists('./numba_func.a'):
            os.unlink('./numba_func.a')
        if os.path.exists('./numba_func.so'):
            os.unlink('./numba_func.so')