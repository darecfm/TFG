#!/bin/bash
# --------------------------------------------------------------------------------------------------------
# Script de inicialización de un nuevo proyecto Hiperlife basado en plantilla.
# Realiza copia, renombrado, configuración y generación de archivos de build para VS Code.
# --------------------------------------------------------------------------------------------------------

### Usa el nombre del proyecto definido por variable de entorno o por defecto "hl-base-project"
PROJECT_NAME="${PROJECT_NAME:-hl-base-project}"
echo "Using Project Name: $PROJECT_NAME"


### 1. Copia el código base si aún no existe en External.
echo "Checking if the base code already exists in External..."
if [ ! -d "/home/hl-user/External/${PROJECT_NAME}" ]; then
    echo "Copying ${PROJECT_NAME} to External..."
    cp -r /home/hl-user/hl-src/hl-base-project "/home/hl-user/External/$PROJECT_NAME" || { echo "Error: No se pudo copiar el proyecto"; exit 1; }

    ## Actualiza el CMakeLists.txt raíz para apuntar al nuevo subdirectorio
    ROOT_CMAKE="/home/hl-user/External/${PROJECT_NAME}/CMakeLists.txt"
    sed -i "s|add_subdirectory(.*)|add_subdirectory(${PROJECT_NAME})|" "$ROOT_CMAKE" || { echo "Error: No se pudo actualizar add_subdirectory"; exit 1; }
fi


### 2. Actualiza el userConfig.cmake con el nuevo nombre de proyecto.
CONFIG_FILE="/home/hl-user/External/${PROJECT_NAME}/userConfig.cmake"
echo "Updating  $CONFIG_FILE..."
sed -i "s/set(PROJECT_NAME .*)/set(PROJECT_NAME ${PROJECT_NAME})/" "$CONFIG_FILE" || { echo "Error: No se pudo actualizar PROJECT_NAME"; exit 1; }
sed -i "s|#list(APPEND APPS .*|list(APPEND APPS ${PROJECT_NAME})|" "$CONFIG_FILE" || { echo "Error: No se pudo actualizar APPS"; exit 1; }


### 3. Renombra directorios y archivos fuente para coincidir con el nombre del proyecto
echo "Renaming directories and files..."
# Solo renombra si EmptyApp existe y el destino NO existe todavía
if [ -d "/home/hl-user/External/${PROJECT_NAME}/EmptyApp" ] && [ ! -d "/home/hl-user/External/${PROJECT_NAME}/${PROJECT_NAME}" ]; then
  mv "/home/hl-user/External/${PROJECT_NAME}/EmptyApp" "/home/hl-user/External/${PROJECT_NAME}/${PROJECT_NAME}" || { echo "Error: No se pudo renombrar EmptyApp"; exit 1; }
fi

if [ -f "/home/hl-user/External/${PROJECT_NAME}/${PROJECT_NAME}/EmptyApp.cpp" ] && [ ! -f "/home/hl-user/External/${PROJECT_NAME}/${PROJECT_NAME}/${PROJECT_NAME}.cpp" ]; then
  mv "/home/hl-user/External/${PROJECT_NAME}/${PROJECT_NAME}/EmptyApp.cpp" "/home/hl-user/External/${PROJECT_NAME}/${PROJECT_NAME}/${PROJECT_NAME}.cpp" || { echo "Error: No se pudo renombrar EmptyApp.cpp"; exit 1; }
fi

#### 4. Crea un nuevo CMakeLists.txt para el ejecutable dentro del subdirectorio
echo "Updating root CMakeLists.txt..."


### 5. Prepara carpetas de build y binarios.
echo "Setting up build configuration in External..."
mkdir -p /home/hl-user/External/${PROJECT_NAME}/build
mkdir -p /home/hl-user/External/hl-bin
cd /home/hl-user/External/${PROJECT_NAME}/build


### 6. Configuración de VS Code para el proyecto (IntelliSense, debug y tareas de build)
VSCODE_DIR="/home/hl-user/External/${PROJECT_NAME}/.vscode"
mkdir -p "$VSCODE_DIR"

## Configuración de rutas de includes y toolchain para IntelliSense  (c_cpp_properties.json)
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
            "intelliSenseMode": "linux-gcc-arm64"
        }
    ],
    "version": 4
}
EOF

## Configuración de depuración y ejecución (launch.json)
cat > "$VSCODE_DIR/launch.json" << EOF
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run hl${PROJECT_NAME}",
      "type": "cppdbg",
      "request": "launch",
      "program": "/home/hl-user/External/hl-bin/hl${PROJECT_NAME}",
      "args": [],
      "stopAtEntry": false,
      "cwd": "\${workspaceFolder}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "/usr/bin/aarch64-linux-gnu-gdb",
      "preLaunchTask": "CMake Build",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ]
    },
    {
      "name": "Debug hl${PROJECT_NAME}",
      "type": "cppdbg",
      "request": "launch",
      "program": "/home/hl-user/External/hl-bin/hl${PROJECT_NAME}",
      "args": [],
      "stopAtEntry": true,
      "cwd": "\${workspaceFolder}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "/usr/bin/aarch64-linux-gnu-gdb",
      "preLaunchTask": "CMake Build",
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
      ]
    }
  ]
}
EOF

### Tarea de build personalizada para VS Code (tasks.json)
cat > "$VSCODE_DIR/tasks.json" << EOF
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "CMake Build",
            "type": "shell",
            "command": "cmake --build build --target install",
            "options": {
                "cwd": "\${workspaceFolder}"
            },
            "group": "build",
            "problemMatcher": []
        },
        {
            "type": "cppbuild",
            "label": "C/C++: g++-11 build active file",
            "command": "/usr/bin/g++-11",
            "args": [
                "-fdiagnostics-color=always",
                "-g",
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}"
            ],
            "options": {
                "cwd": "\${fileDirname}"
            },
            "problemMatcher": [
                "\$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "detail": "Task generated by Debugger."
        }
    ]
}
EOF

mkdir -p /home/hl-user/.local/share/CMakeTools/
cat > "/home/hl-user/.local/share/CMakeTools/cmake-tools-kits.json" << EOF
[
  {
    "name": "GCC 11.4.0 aarch64-linux-gnu",
    "compilers": {
      "C": "/usr/bin/aarch64-linux-gnu-gcc",
      "CXX": "/usr/bin/aarch64-linux-gnu-g++"
    },
    "isTrusted": true
  }
]
EOF

cat > "$VSCODE_DIR/settings.json" << EOF
{
  "cmake.configureOnOpen": true,
  "cmake.generator": "Unix Makefiles",
  "cmake.sourceDirectory": "\${workspaceFolder}",
  "cmake.buildDirectory": "\${workspaceFolder}/build",
  "cmake.configureArgs": [
    "-DHL_BASE_PATH=/home/hl-user/hl-bin"
  ]
}
EOF

# 7. Compilación y log de salida.
echo "Compiling source code..."
#cmake .. -D CMAKE_INSTALL_PREFIX=/home/hl-user/External/hl-bin -D HL_BASE_PATH=/home/hl-user/hl-bin > cmake.log 2>&1 || { echo "Error: CMake falló"; exit 1; }
#cmake .. -DCMAKE_INSTALL_PREFIX=/home/hl-user/External/hl-bin -DHL_BASE_PATH=/home/hl-user/hl-bin -DCMAKE_EXPORT_COMPILE_COMMANDS=ON > cmake.log 2>&1 || { echo "Error: CMake falló"; exit 1; }
cmake -DCMAKE_BUILD_TYPE:STRING=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE -DCMAKE_C_COMPILER:FILEPATH=/usr/bin/aarch64-linux-gnu-gcc -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/aarch64-linux-gnu-g++ -DHL_BASE_PATH=/home/hl-user/hl-bin --no-warn-unused-cli -S/home/hl-user/External/${PROJECT_NAME} -B/home/hl-user/External/${PROJECT_NAME}/build -G "Unix Makefiles"
#cmake -DCMAKE_BUILD_TYPE:STRING=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE -DCMAKE_C_COMPILER:FILEPATH=/usr/bin/mpicc -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/mpicxx -DHL_BASE_PATH=/home/hl-user/hl-bin --no-warn-unused-cli -S/home/hl-user/External/DaniApp -B/home/hl-user/External/DaniApp/build -G "Unix Makefiles"
make install > cmake.log 2>&1 || { echo "Error: make install falló"; exit 1; }
echo "Compilation details are available in cmake.log"

## Verifica que se generó el ejecutable correctamente en el directorio de instalación
#ls -l /home/hl-user/External/hl-bin/hl${PROJECT_NAME} || { echo "Error: Binario no encontrado"; exit 1; }

echo "Initialization completed"




#Ventajas de hacer esto 
    #Verifica si hl-base-project está en External/. Si no, lo copia desde /hl-src/hl-base-project.
    #Compila el código solo si no ha sido compilado antes, evitando recompilaciones innecesarias.
    #crea un archivo compiled.flag para saber si ya fue compilado antes

#Que hemos conseguido con esto con el compose pues:
    #✔ Volumen único (External) para organizar todo sin sobrescribir archivos.
    #Ejecuta initHL.sh en el command para gestionar la inicialización y compilación.
    #Verifica si el código ya está copiado antes de duplicarlo.
     #Compila solo si es necesario, optimizando el tiempo de arranque.