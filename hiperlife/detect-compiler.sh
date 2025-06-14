#!/bin/bash

# Detect the architecture
ARCH=$(uname -m)

# Set the appropriate compilers for that architecture
if [ "$ARCH" = "aarch64" ]; then
    C_COMPILER="/usr/bin/aarch64-linux-gnu-gcc"
    CXX_COMPILER="/usr/bin/aarch64-linux-gnu-g++"
else
    C_COMPILER="/usr/bin/gcc"
    CXX_COMPILER="/usr/bin/g++"
fi

# Export the resulting variables
export C_COMPILER
export CXX_COMPILER