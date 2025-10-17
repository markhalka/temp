# NRT (Numba Runtime) Build System

This directory contains an improved build system for creating the NRT (Numba Runtime) shared library that exposes the necessary symbols for external linking.

## Overview

The original `build_nrt.sh` script has been refactored into a more maintainable and flexible build system consisting of:

- **Makefile**: Main build configuration with proper dependencies
- **python_stub.h**: Simple Python.h stub for standalone compilation
- **symbol_exposer.py**: Advanced symbol visibility control tools
- **Enhanced symbol exposure**: Multiple approaches to expose hidden symbols

## Symbol Visibility Solutions

The main challenge with the original build was that Numba's runtime functions are annotated with `VISIBILITY_HIDDEN`, making them unavailable for external linking. This build system addresses this through multiple approaches:

### 1. Header Override
- Uses `visibility_override.h` to redefine visibility macros before compilation
- Forces all `VISIBILITY_HIDDEN` symbols to use `visibility("default")`
- Applied via `-include visibility_override.h` compiler flag

### 2. Linker Version Scripts
- Creates precise control over which symbols are exported
- Uses GNU linker version scripts to explicitly list exported symbols
- Hides all other symbols to maintain clean ABI

### 3. Wrapper Functions
- Provides explicit wrapper functions for critical symbols
- Ensures symbols are always available regardless of original visibility

### 4. Static Compilation Support
- Supports both shared and static library builds
- Static libraries naturally expose all symbols

## Build Targets

### Basic Targets
```bash
make all          # Build both shared and static libraries (default)
make shared       # Build only shared library
make static       # Build only static library
make clean        # Remove all build artifacts
make help         # Show all available targets
```

### Analysis Targets
```bash
make analyze-symbols  # Analyze symbols in built library
make test-static      # Test static library compilation
make symbol-report    # Generate comprehensive symbol report
make info            # Display library information
```

## File Structure

```
├── Makefile                    # Main build configuration
├── python_stub.h             # Python.h stub for standalone compilation
├── visibility_override.h     # Overrides Numba's visibility macros
├── symbol_exposer.py          # Symbol visibility tools
├── python_stubs.c             # Python API stubs
├── build_nrt.sh              # Original build script (deprecated)
└── numba/                    # Numba source code
    └── numba/
        ├── core/runtime/     # NRT source files
        └── cext/            # C extension files
```

## Generated Output

The build system creates:

```
nrt_lib/
├── include/
│   ├── Python.h              # Generated Python.h stub
│   ├── nrt.h                 # NRT header
│   ├── nrt_external.h        # External API header
│   ├── cext.h                # C extension header
│   ├── listobject.h          # List object header
│   ├── dictobject.h          # Dict object header
│   └── _numba_common.h       # Common definitions
└── lib/
    ├── libnrt.so.1.0.0       # Shared library
    ├── libnrt.so.1 -> libnrt.so.1.0.0
    ├── libnrt.so -> libnrt.so.1
    ├── libnrt.a              # Static library
    └── pkgconfig/
        └── nrt.pc            # pkg-config file
```

## Key Improvements Over Original Script

1. **Modular Design**: Separated concerns into focused scripts
2. **Proper Dependencies**: Makefile handles build dependencies correctly
3. **Symbol Visibility**: Multiple approaches to expose hidden symbols
4. **Analysis Tools**: Built-in symbol analysis and reporting
5. **Flexibility**: Easy to modify and extend
6. **Documentation**: Clear documentation and help system

## Usage Examples

### Basic Build
```bash
# Build everything
make

# Build only shared library
make shared

# Clean and rebuild
make clean && make
```

### Symbol Analysis
```bash
# Check what symbols are exported
make analyze-symbols

# Generate detailed symbol report
make symbol-report

# Test static library
make test-static
```

### Development Workflow
```bash
# Clean build
make clean

# Build with verbose output
make -j4

# Check symbols
make analyze-symbols

# Generate report
make symbol-report
```

## Troubleshooting

### Common Issues

1. **Missing Python**: Ensure `python3` is available
2. **Missing Compilers**: Install `gcc` and `g++`
3. **Permission Issues**: Ensure write permissions to build directories
4. **Symbol Visibility**: Use `make analyze-symbols` to verify symbol exposure

### Debugging

```bash
# Check build dependencies
make -n all

# Verbose build output
make V=1

# Check specific target
make -n shared

# Analyze symbols after build
make analyze-symbols
```

## Advanced Configuration

### Custom Symbol Lists
Edit `symbol_exposer.py` to modify the list of exported symbols.

### Compiler Flags
Modify `CXXFLAGS` and `CFLAGS` in the Makefile for different optimization levels.

### Linker Options
Adjust linker flags in the shared library target for different linking requirements.

## Migration from build_nrt.sh

The original `build_nrt.sh` script is still present but deprecated. To migrate:

1. Use `make` instead of `./build_nrt.sh`
2. Use `make clean` instead of manual cleanup
3. Use `make analyze-symbols` for symbol verification
4. Use `make help` for available options

The new system provides the same functionality with better organization and additional features.
