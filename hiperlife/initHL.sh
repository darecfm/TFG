#!/bin/bash

#===============================================================================
# HiperLife Project Initialization Script
# Author: [Diego Escobedo Cueva]
# Description: Initializes a new HiperLife project with proper configuration
#             and build environment setup.
#===============================================================================

#-------------------------------------------------------------------------------
# Environment Setup and Validation
#-------------------------------------------------------------------------------

# Detectar arquitectura y establecer compiladores
if [ -f "/home/hl-user/bin/detect-compiler.sh" ]; then
    source /home/hl-user/bin/detect-compiler.sh
    echo "INFO" "Detected architecture: $(uname -m)"
    echo "INFO" "Using compiler: ${C_COMPILER:-/usr/bin/gcc}"
fi

# Default environment variables
PROJECT_NAME="${PROJECT_NAME:-Prove0001}"
DEBUG_MODE="${DEBUG_MODE:-1}"
BUILD_DIR="${BUILD_DIR:-/home/hl-user/External/${PROJECT_NAME}/build}"
SOURCE_DIR="${SOURCE_DIR:-/home/hl-user/External/${PROJECT_NAME}}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/home/hl-user/External/hl-bin}"
C_COMPILER="${C_COMPILER:-/usr/bin/gcc}"
CXX_COMPILER="${CXX_COMPILER:-/usr/bin/g++}"
NUM_THREADS="${NUM_THREADS:--1}"
HL_BASE_PATH="${HL_BASE_PATH:-/home/hl-user/hl-bin}"
ENABLE_TESTS="${ENABLE_TESTS:-1}"
ENABLE_EXAMPLES="${ENABLE_EXAMPLES:-1}"
CMAKE_FLAGS="${CMAKE_FLAGS:-}"

# Display configuration
print_configuration() {
    echo "====== Environment Configuration ======"
    echo "Project name:     $PROJECT_NAME"
    echo "Debug mode:       $DEBUG_MODE"
    echo "Build directory:  $BUILD_DIR"
    echo "Source directory: $SOURCE_DIR"
    echo "Install prefix:   $INSTALL_PREFIX"
    echo "C Compiler:      $C_COMPILER"
    echo "C++ Compiler:    $CXX_COMPILER"
    echo "Build threads:    $NUM_THREADS"
    echo "====== Project Setup Steps ======"
}

#-------------------------------------------------------------------------------
# Project Setup Functions
#-------------------------------------------------------------------------------
setup_project_structure() {
    echo "Setting up project structure..."
    mkdir -p "/home/hl-user/External"
    if [ ! -d "/home/hl-user/External/${PROJECT_NAME}" ]; then
        echo "Creating new project from template..."
        cp -r /home/hl-user/hl-src/hl-base-project "/home/hl-user/External/$PROJECT_NAME" || {
            echo "ERROR: Failed to copy project template"
            return 1
        }
        
        # Update root CMakeLists.txt
        local ROOT_CMAKE="/home/hl-user/External/${PROJECT_NAME}/CMakeLists.txt"
        sed -i "s|add_subdirectory(.*)|add_subdirectory(${PROJECT_NAME})|" "$ROOT_CMAKE" || {
            echo "ERROR: Failed to update add_subdirectory"
            return 1
        }
    fi
}

update_project_config() {
    echo "Updating project configuration..."
    local config_file="/home/hl-user/External/${PROJECT_NAME}/userConfig.cmake"
    sed -i "s/set(PROJECT_NAME .*)/set(PROJECT_NAME ${PROJECT_NAME})/" "$config_file" || {
        echo "ERROR: Failed to update PROJECT_NAME"
        return 1
    }
    sed -i "s|#list(APPEND APPS .*|list(APPEND APPS ${PROJECT_NAME})|" "$config_file" || {
        echo "ERROR: Failed to update APPS"
        return 1
    }
}

rename_project_files() {
    echo "Renaming project files and directories..."
    local base_dir="/home/hl-user/External/${PROJECT_NAME}"
    
    # Rename EmptyApp directory
    if [ -d "${base_dir}/EmptyApp" ] && [ ! -d "${base_dir}/${PROJECT_NAME}" ]; then
        mv "${base_dir}/EmptyApp" "${base_dir}/${PROJECT_NAME}" || {
            echo "ERROR: Failed to rename EmptyApp directory"
            return 1
        }
    fi
    
    # Rename EmptyApp.cpp file
    if [ -f "${base_dir}/${PROJECT_NAME}/EmptyApp.cpp" ] && [ ! -f "${base_dir}/${PROJECT_NAME}/${PROJECT_NAME}.cpp" ]; then
        mv "${base_dir}/${PROJECT_NAME}/EmptyApp.cpp" "${base_dir}/${PROJECT_NAME}/${PROJECT_NAME}.cpp" || {
            echo "ERROR: Failed to rename EmptyApp.cpp"
            return 1
        }
    fi
}

#-------------------------------------------------------------------------------
# VSCode Configuration
#-------------------------------------------------------------------------------
setup_vscode_config() {
    echo "Configuring VSCode environment..."
    local VSCODE_DIR="/home/hl-user/External/${PROJECT_NAME}/.vscode"
    mkdir -p "$VSCODE_DIR"

    # Configure IntelliSense settings
    cat > "$VSCODE_DIR/c_cpp_properties.json" << EOF
{
    "configurations": [
        {
            "name": "Linux",
            "compileCommands": "\${workspaceFolder}/build/compile_commands.json",
            "includePath": [
                "\${workspaceFolder}/**",
                "/home/hl-user/hl-bin/include",
                "/home/hl-user/hl-bin/third-party/Trilinos/include",
                "/usr/lib/aarch64-linux-gnu/openmpi/include"
            ], 
            "compilerPath": "/usr/bin/aarch64-linux-gnu-g++",
            "cStandard": "c17",
            "cppStandard": "gnu++17",
            "intelliSenseMode": "linux-gcc-arm64",
            "configurationProvider": "ms-vscode.cmake-tools"
        }
    ],
    "version": 4
}
EOF

    # Configure debug and launch settings
    cat > "$VSCODE_DIR/launch.json" << EOF
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug hl${PROJECT_NAME}",
      "type": "cppdbg",
      "request": "launch",
      "program": "${INSTALL_PREFIX}/hl${PROJECT_NAME}",
      "args": [],
      "stopAtEntry": true,
      "cwd": "\${workspaceFolder}",
      "environment": [
        { "name": "HL_BASE_PATH", "value": "${HL_BASE_PATH}" },
        { "name": "DEBUG_MODE", "value": "${DEBUG_MODE}" }
      ],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "${CXX_COMPILER%++-*}gdb",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        },
        {
          "description": "Set disassembly flavor to Intel",
          "text": "-gdb-set disassembly-flavor intel",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "Build Debug",
      "sourceFileMap": {
        "/home/hl-user/External": "\${workspaceFolder}"
      }
    },
    {
      "name": "Run hl${PROJECT_NAME}",
      "type": "cppdbg",
      "request": "launch",
      "program": "${INSTALL_PREFIX}/hl${PROJECT_NAME}",
      "args": [],
      "stopAtEntry": false,
      "cwd": "\${workspaceFolder}",
      "environment": [
        { "name": "HL_BASE_PATH", "value": "${HL_BASE_PATH}" }
      ],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "${CXX_COMPILER%++-*}gdb",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "Build Release"
    }
  ]
}
EOF

    # Configure build tasks
    cat > "$VSCODE_DIR/tasks.json" << EOF
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build Debug",
            "type": "shell",
            "command": "cmake --build build --target install --config Debug -- -j${NUM_THREADS}",
            "options": {
                "cwd": "\${workspaceFolder}"
            },
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": ["\$gcc"]
        },
        {
            "label": "Build Release",
            "type": "shell",
            "command": "cmake --build build --target install --config Release -- -j${NUM_THREADS}",
            "options": {
                "cwd": "\${workspaceFolder}"
            },
            "group": "build",
            "problemMatcher": ["\$gcc"]
        }
    ]
}
EOF

    # Configure CMake Tools settings
    mkdir -p /home/hl-user/.local/share/CMakeTools/
    cat > "/home/hl-user/.local/share/CMakeTools/cmake-tools-kits.json" << EOF
[
  {
    "name": "GCC 11.4.0 aarch64-linux-gnu",
    "compilers": {
      "C": "${C_COMPILER}",
      "CXX": "${CXX_COMPILER}"
    },
    "isTrusted": true
  }
]
EOF

    # Configure VSCode workspace settings
    cat > "$VSCODE_DIR/settings.json" << EOF
{
  "cmake.configureOnOpen": true,
  "cmake.generator": "Unix Makefiles",
  "cmake.sourceDirectory": "\${workspaceFolder}",
  "cmake.buildDirectory": "\${workspaceFolder}/build",
  "cmake.configureArgs": [
    "-DHL_BASE_PATH=${HL_BASE_PATH}"
  ]
}
EOF

    # Verify VSCode configuration
    for file in "launch.json" "tasks.json" "settings.json" "c_cpp_properties.json"; do
        if [ ! -f "$VSCODE_DIR/$file" ]; then
            echo "ERROR: Failed to create $file"
            return 1
        fi
    done

    echo "VSCode configuration completed successfully"
    return 0
}

#-------------------------------------------------------------------------------
# Build Configuration
#-------------------------------------------------------------------------------
configure_build() {
    echo "Configuring build system..."
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR" || return 1

    # Configure CMake
    cmake -DCMAKE_BUILD_TYPE:STRING=Debug \
          -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
          -DCMAKE_C_COMPILER:FILEPATH=${C_COMPILER} \
          -DCMAKE_CXX_COMPILER:FILEPATH=${CXX_COMPILER} \
          -DHL_BASE_PATH=${HL_BASE_PATH} \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DCMAKE_CXX_FLAGS="-g3" \
          -DCMAKE_C_FLAGS="-g3" \
          -DENABLE_TESTS=${ENABLE_TESTS} \
          -DENABLE_EXAMPLES=${ENABLE_EXAMPLES} \
          -DCMAKE_BUILD_TYPE=${DEBUG_MODE:+Debug}${DEBUG_MODE:-Release} \
          ${CMAKE_FLAGS} \
          --no-warn-unused-cli \
          -S${SOURCE_DIR} \
          -B${BUILD_DIR} \
          -G "Unix Makefiles" \
          > cmake.log 2>&1 || {
              echo "ERROR: CMake configuration failed"
              return 1
          }

    # Build and install
    make -j${NUM_THREADS} install > make.log 2>&1 || {
        echo "ERROR: Build failed"
        return 1
    }

    echo "Build configuration completed successfully"
    return 0
}

#-------------------------------------------------------------------------------
# Validation Functions
#-------------------------------------------------------------------------------
validate_installation() {
    echo "Validating installation..."
    local executable="${INSTALL_PREFIX}/hl${PROJECT_NAME}"
    
    # Check executable
    if [ ! -f "$executable" ]; then
        echo "ERROR: Executable not found"
        return 1
    fi
    
    # Check debug symbols
    if readelf -S "$executable" | grep -q .debug_info; then
        echo "SUCCESS: Debug symbols found"
    else
        echo "WARNING: No debug symbols found"
    fi
}

#-------------------------------------------------------------------------------
# Logging and System Detection
#-------------------------------------------------------------------------------
log_message() {
    local level=$1
    local message=$2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message"
}

detect_system_resources() {
    local available_memory=$(free -g | awk '/^Mem:/{print $2}')
    local available_cores=$(nproc)
    
    # Manejar el valor -1 para usar todos los cores disponibles
    if [ "$NUM_THREADS" = "-1" ]; then
        NUM_THREADS=$available_cores
    elif [ -z "$NUM_THREADS" ]; then
        NUM_THREADS=$available_cores
    fi

    log_message "INFO" "Detected $available_cores cores, using $NUM_THREADS threads"
    log_message "INFO" "Available memory: ${available_memory}G"
}

#-------------------------------------------------------------------------------
# Main Execution
#-------------------------------------------------------------------------------
main() {
    log_message "INFO" "Starting project initialization"
    detect_system_resources
    print_configuration

    setup_project_structure || exit 1
    update_project_config || exit 1
    rename_project_files || exit 1
    setup_vscode_config || exit 1
    configure_build || exit 1
    validate_installation || exit 1
    echo "=========================="
    echo "Project initialization completed successfully"
    echo "Click on the ''Remote Explorer'' icon... "
}

# Execute main function
main