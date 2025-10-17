# Makefile for building NRT (Numba Runtime) static library
# Simplified version focusing on static compilation

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

# Directories
NRT_SRC_DIR := ./numba/numba/core/runtime
CEXT_SRC_DIR := ./numba/numba/cext
NUMBA_SRC_DIR := ./numba/numba
BUILD_DIR := ./nrt_build
INSTALL_DIR := ./nrt_lib

# Compiler flags
CXX := g++
CC := gcc
CXXFLAGS := -fPIC -g -O0 -std=c++11
CFLAGS := -fPIC -g -O0 -w -Wno-builtin-declaration-mismatch

# Include directories
INCLUDES := -I. -I$(NUMBA_SRC_DIR) -I$(INSTALL_DIR)/include

# Source files
NRT_SOURCES := $(NRT_SRC_DIR)/nrt.cpp
CEXT_SOURCES := $(CEXT_SRC_DIR)/listobject.c $(CEXT_SRC_DIR)/dictobject.c $(CEXT_SRC_DIR)/utils.c
STUB_SOURCES := python_stubs.c

# Object files
NRT_OBJECTS := $(BUILD_DIR)/nrt.o
CEXT_OBJECTS := $(BUILD_DIR)/listobject.o $(BUILD_DIR)/dictobject.o $(BUILD_DIR)/utils.o
STUB_OBJECTS := $(BUILD_DIR)/python_stubs.o
ALL_OBJECTS := $(NRT_OBJECTS) $(CEXT_OBJECTS) $(STUB_OBJECTS)

# Library files
STATIC_LIB := $(INSTALL_DIR)/lib/libnrt.a

# Default target
.PHONY: all
all: $(STATIC_LIB)
	@echo -e "$(GREEN)NRT static library built successfully!$(NC)"
	@echo -e "$(GREEN)Static library: $(STATIC_LIB)$(NC)"
	@echo -e "$(GREEN)Headers: $(INSTALL_DIR)/include/$(NC)"

# Create directories
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(INSTALL_DIR)/include:
	@mkdir -p $(INSTALL_DIR)/include

$(INSTALL_DIR)/lib:
	@mkdir -p $(INSTALL_DIR)/lib

$(INSTALL_DIR)/lib/pkgconfig:
	@mkdir -p $(INSTALL_DIR)/lib/pkgconfig

# Copy Python.h stub
$(INSTALL_DIR)/include/Python.h: python_stub.h | $(INSTALL_DIR)/include
	@echo -e "$(YELLOW)Copying Python.h stub...$(NC)"
	@cp python_stub.h $(INSTALL_DIR)/include/Python.h

# Copy headers
$(INSTALL_DIR)/include/nrt.h: $(NRT_SRC_DIR)/nrt.h | $(INSTALL_DIR)/include
	@echo -e "$(YELLOW)Copying headers...$(NC)"
	@cp $(NRT_SRC_DIR)/nrt.h $(INSTALL_DIR)/include/
	@cp $(NRT_SRC_DIR)/nrt_external.h $(INSTALL_DIR)/include/
	@cp $(CEXT_SRC_DIR)/cext.h $(INSTALL_DIR)/include/
	@cp $(CEXT_SRC_DIR)/listobject.h $(INSTALL_DIR)/include/
	@cp $(CEXT_SRC_DIR)/dictobject.h $(INSTALL_DIR)/include/
	@cp $(NUMBA_SRC_DIR)/_numba_common.h $(INSTALL_DIR)/include/
	@echo -e "$(YELLOW)Creating symlink for relative paths...$(NC)"
	@ln -sf $(NUMBA_SRC_DIR)/_numba_common.h _numba_common.h

# Compile NRT C++ source
$(BUILD_DIR)/nrt.o: $(NRT_SRC_DIR)/nrt.cpp $(INSTALL_DIR)/include/Python.h $(INSTALL_DIR)/include/nrt.h | $(BUILD_DIR)
	@echo -e "$(YELLOW)Compiling nrt.cpp...$(NC)"
	@cd $(NUMBA_SRC_DIR) && $(CXX) -c $(CXXFLAGS) -I. -I$(shell realpath $(INSTALL_DIR)/include) core/runtime/nrt.cpp -o $(shell realpath $@)

# Compile C extension sources
$(BUILD_DIR)/listobject.o: $(CEXT_SRC_DIR)/listobject.c $(INSTALL_DIR)/include/Python.h $(INSTALL_DIR)/include/nrt.h | $(BUILD_DIR)
	@echo -e "$(YELLOW)Compiling listobject.c...$(NC)"
	@cd $(NUMBA_SRC_DIR) && $(CC) -c $(CFLAGS) -I. -I$(shell realpath $(INSTALL_DIR)/include) cext/listobject.c -o $(shell realpath $@)

$(BUILD_DIR)/dictobject.o: $(CEXT_SRC_DIR)/dictobject.c $(INSTALL_DIR)/include/Python.h $(INSTALL_DIR)/include/nrt.h | $(BUILD_DIR)
	@echo -e "$(YELLOW)Compiling dictobject.c...$(NC)"
	@cd $(NUMBA_SRC_DIR) && $(CC) -c $(CFLAGS) -I. -I$(shell realpath $(INSTALL_DIR)/include) cext/dictobject.c -o $(shell realpath $@)

$(BUILD_DIR)/utils.o: $(CEXT_SRC_DIR)/utils.c $(INSTALL_DIR)/include/Python.h $(INSTALL_DIR)/include/nrt.h | $(BUILD_DIR)
	@echo -e "$(YELLOW)Compiling utils.c...$(NC)"
	@cd $(NUMBA_SRC_DIR) && $(CC) -c $(CFLAGS) -I. -I$(shell realpath $(INSTALL_DIR)/include) cext/utils.c -o $(shell realpath $@)

# Compile Python stubs
$(BUILD_DIR)/python_stubs.o: python_stubs.c $(INSTALL_DIR)/include/Python.h | $(BUILD_DIR)
	@echo -e "$(YELLOW)Compiling Python stubs...$(NC)"
	@$(CC) -c $(CFLAGS) -I$(INSTALL_DIR)/include python_stubs.c -o $@

# Create static library
$(STATIC_LIB): $(ALL_OBJECTS) | $(INSTALL_DIR)/lib
	@echo -e "$(YELLOW)Creating static library...$(NC)"
	@ar rcs $@ $(ALL_OBJECTS)

# Clean build artifacts
.PHONY: clean
clean:
	@echo -e "$(YELLOW)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR)
	@rm -rf $(INSTALL_DIR)
	@rm -f _numba_common.h

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all     - Build static library (default)"
	@echo "  clean   - Remove all build artifacts"
	@echo "  help    - Show this help message"
