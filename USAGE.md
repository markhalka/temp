# Usage Guide for Updated Build System

## Quick Start

1. **Build the NRT library:**
   ```bash
   make
   ```

2. **Run the test:**
   ```bash
   python3 test.py
   ```

## What Changed

### test.py Updates
- **Build check**: Automatically checks if NRT library is built before running
- **Shared library linking**: Uses `-lnrt` instead of static library linking
- **Better error handling**: Provides helpful messages if library is missing
- **Cleaner compilation**: Simplified linking process

### main.cpp Updates  
- **Proper headers**: Uses `#include "nrt.h"` and `#include "nrt_external.h"` from our build
- **Better output**: More informative console output with clear sections
- **Error handling**: Enhanced error reporting

## Build System Benefits

1. **Symbol Visibility**: The new build system properly exposes NRT symbols
2. **Modular Design**: Clean separation of concerns with Makefile targets
3. **Easy Maintenance**: Simple to modify and extend
4. **Better Testing**: Built-in analysis tools for symbol verification

## Available Make Targets

```bash
make              # Build everything
make shared       # Build only shared library  
make static       # Build only static library
make analyze-symbols  # Check exported symbols
make symbol-report   # Generate detailed symbol report
make clean        # Clean build artifacts
make help         # Show all targets
```

## Troubleshooting

If you get symbol visibility errors:
1. Run `make analyze-symbols` to check what symbols are exported
2. Use `make symbol-report` for detailed analysis
3. Ensure you're using the shared library (`-lnrt`) not static (`libnrt.a`)

The new build system should resolve the symbol visibility issues that were present in the original `build_nrt.sh` script.
