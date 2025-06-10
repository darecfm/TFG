# TFG
---

## **Pasos para crear la imagen Docker de hiperlife**

---

**1. Asegúrate de tener:**

En tu carpeta ( tools/docker/):

```
├── Dockerfile-app          # Dockerfile personalizado
├── docker-compose.yaml     # Define el servicio del contenedor
├── initHL.sh               # Script de inicialización y compilación
├── .env                    # Variables de entorno personalizables
```
----------

**2. Construye la imagen**

Desde la carpeta donde está  Dockerfile-app, ejecuta:
```
docker build -t darecfm/hiperlife-app:latest -f Dockerfile-app .
```

•  darecfm/hiperlife-app: nombre de tu imagen personalizada, puedes poner el nombre que desees. Pero si la editas acuerdate de cambiar la imagen en el file docker-compose.yaml

•  Dockerfile-app: tu archivo Dockerfile.

----------

**3. Levanta el contenedor**

  • Inicialización por defecto (utiliza "hl-base-project" como nombre del proyecto):
```
docker compose up 
```

  • Inicialización personalizada (el usuario define el nombre del proyecto):

```
PROJECT_NAME=Nombre-del-proyecto docker compose up
```

  • También puedes personalizar el número de Threads a utilizar:
```
PROJECT_NAME=Nombre-del-proyecto NUM_THREADS=5 DEBUG_MODE=1 docker-compose up
```

 • Si ya has construido esta imagen previamente, puedes omitir `--build`. Sin embargo, incluirlo fuerza la reconstrucción de la imagen Docker, lo cual es útil si has hecho cambios en el `Dockerfile` o archivos del entorno que deseas aplicar.
```
PROJECT_NAME=nombre-del-proyecto docker compose up --build
```


Esto:

•  Arranca el contenedor  hiperlife-container

•  Ejecuta automáticamente  initHL.sh  dentro del contenedor

•  Copia y compila el proyecto  hl-base-project

•  Deja una terminal activa lista para trabajar

----------

**4. Finalizar Docker**

```
docker compose down                         # Para parar y eliminar el contenedor
docker rmi darecfm/hiperlife-app:latest     # Para borrar la imagen si lo deseas
```

---
--------------
---
---

---
---
## **PASOS PARA PROBAR TU APP CON DOCKER + HIPERLIFE + VS CODE**
---

A continuación se describe, de forma técnica, el flujo completo de preparación, configuración y ejecución de una aplicación basada en Hiperlife dentro de un contenedor Docker, usando Visual Studio Code como IDE.

## 1. Requisitos Previos

#### 1. Docker

- Debes tener **Docker Engine** (versión **20.x o superior**) y **Docker Desktop** (versión **4.x o superior**) instalado y en ejecución en tu sistema operativo (Linux o macOS).
- Verifica su funcionamiento con los siguientes comandos:

  ```bash
  docker version
  docker info
  ```
  
#### 2. Visual Studio Code (VS Code)

- **Versión recomendada:** ≥ 1.100 (o la versión LTS más reciente).
- Debe estar **instalado localmente** y actualizado.



#### 3. Repositorio hiperlife

- Código fuente de ejemplo (por ejemplo: `hl-base-project`) o tu propio proyecto basado en el framework Hiperlife.

- **Estructura esperada (dentro de External/):**

      ```
      External/                            
      ├── hl-bin/                            
      │   └── hlnombre-del-proyecto              # Binario compilado e instalado (por CMake + make install)
      └── nombre-del-proyecto/                   # Proyecto principal   
          ├── userConfig.cmake                   # Define PROJECT_NAME y lista de aplicaciones
          ├── README.md                          # Documentación técnica del proyecto
          ├── CMakeLists.txt                     # CMake raíz que incluye subproyecto nombre-del-proyecto/
          ├── .gitignore     
          └── .vscode/                          # Configuración de VS Code (compilación, debug, IntelliSense)
          │    ├── launch.json                  # Configura ejecución y depuración de hlPrueba70
          │    ├── tasks.json                   # Tarea personalizada de compilación con MPI + hiperlife   
          │    ├── c_cpp_properties.json        # Rutas de include, toolchain e IntelliSense
          │    └── settings.json                # Args de configuración para CMake (HL_BASE_PATH, etc.)
          └──build/                             # Artefactos de build generados por CMake
          │    ├── CMakeFiles/                  # Archivos internos de CMake 
          │    ├── nombre-del-proyecto/         # Carpeta que contiene el binario compilado            
          │    ├── cmake_install.cmake          # Script de instalación generado
          │    ├── cmake.log                    # Log generado por `cmake .. > cmake.log
          │    ├── CMakeCache.txt               # Cache de opciones CMake
          │    │── compile_commands.json        # índice generado automáticamente por CMake
          │    ├── install_manifest.txt         # Registro de archivos instalados
          │    └── Makefile                     # Makefile generado para compilar
          └── nombre-del-proyecto/              # Subdirectorio con la aplicación principal
              ├── nombre-del-proyecto.cpp       # Fichero fuente principal de la app
              ├── AuxEmptyApp.cpp               # Fichero auxiliar (por ejemplo, para funciones separadas)
              ├── AuxEmptyApp.h                 # Cabecera del auxiliar
              └── CMakeLists.txt                # CMake específico del ejecutable hlPrueba70
      ```
    > **Nota:**  Puedes reemplazar todas las apariciones de nombre-del-proyecto si generas otro proyecto (PRueba80, SimXYZ, etc.) automáticamente desde tu script initHL.sh.       


## 2. Extensiones necesarias en Visual Studio Code

Para trabajar correctamente con el entorno Dockerizado de hiperlife, asegúrate de tener instaladas las siguientes extensiones en VS Code:

#### • Dev Containers

- **ID:** `ms-vscode-remote.remote-containers`  
- **Funcionalidad:** Permite abrir carpetas de proyecto y entornos de desarrollo directamente dentro de contenedores Docker desde VS Code. Esta extensión es esencial para habilitar la experiencia completa de desarrollo en contenedores (devcontainer.json, volumes, comandos postCreate, etc.).

#### • C/C++

- **ID:** `ms-vscode.cpptools`  
- **Funcionalidad:** Habilita IntelliSense, exploración de definiciones, compilación y depuración (GDB/LLDB) para proyectos en C/C++.

### • CMake

- **ID:** `twxs.cmake`  
- **Funcionalidad:** Proporciona soporte básico para la sintaxis y el resaltado en archivos y scripts `CMakeLists.txt`.

### • CMake Tools

- **ID:** `ms-vscode.cmake-tools`  
- **Funcionalidad:** Añade integración avanzada de CMake en VS Code:  
  gestiona configuración, generación y compilación de proyectos CMake desde la interfaz gráfica, con comandos rápidos, lista de targets, tareas automáticas y soporte para `compile_commands.json`.

> **Nota:** Tras instalar estas extensiones, reinicia Visual Studio Code para asegurar que se cargan correctamente en el contenedor.


## 3. Configuración de VS Code para Dev Containers

#### 1. Abrir VS Code

- Abre Visual Studio Code de forma normal (sin contenedor aún).

#### 2. Verificar Extensiones

- En la barra lateral izquierda, haz clic en el ícono de **Extensiones** (o pulsa `Ctrl+Shift+X`).
- Confirma que las extensiones **Dev Containers**, **C/C++**, **CMake**, **CMake tools**, **Dev Containers**, **Docker** y **Docker Explorer** estén instaladas y habilitadas.

#### 3. Abrir Remote Explorer

- Pulsa `Ctrl+Shift+E` (o haz clic en el ícono de “Explorer”).
- Desde la barra lateral, selecciona el ícono de **Remote Explorer** (forma de monitor con flecha).
- En la sección **Dev Containers**, verás los contenedores Docker construidos/preparados (por ejemplo, `docker-hiperlife-container-1` si ya existe o tu propia etiqueta `hiperlife-dev:latest`).

#### 4. Iniciar y adjuntar un contenedor

- Si ya tienes un contenedor en ejecución (por ejemplo, `docker-hiperlife-container-1`), aparecerá en la lista.
- De lo contrario, VS Code detectará la carpeta `.devcontainer` (si existe) o te sugerirá crearla.

**Para adjuntar:**
- `Attach in Current Window` (Flecha ↪): abre el contenedor en la **misma ventana** de VS Code.
- `Attach in New Window` (Ícono de ventana): abre una **nueva instancia** de VS Code conectada al contenedor.

-  Selecciona la opción deseada. VS Code realizará automáticamente:

    1. Se conecta a Docker.

    2. Inicio del contenedor (si aún no está corriendo).

    3. Montaje de tu carpeta de proyecto dentro del contenedor.
    4. Configuración de las rutas de desarrollo (IntelliSense, terminal, etc.).

>  **Nota:**  
> Si nunca has creado un `devcontainer` para tu proyecto, VS Code te guiará para generar un archivo `.devcontainer/devcontainer.json` donde puedes especificar la imagen (`hiperlife-dev:latest`) y el `postCreateCommand` (por ejemplo: `cmake . && make install`).


## 4. Navegar al Directorio de la Aplicación dentro del Contenedor

#### 1. Abrir la Terminal Integrada
- Dentro de VS Code (ya conectado al contenedor), dirigete a la parte superior en Terminal > New terminal
- Verifica que estás dentro del contenedor observando el prompt del sistema, que debería mostrar algo como: `(hl-user@container-id) /home/hl-user/External/nombre-del-proyecto`

#### 2. Cambiar al Directorio de tu Aplicación "Open Workspace"
- Antes de compilar o depurar, es imprescindible que VS Code esté apuntando directamente al directorio de tu aplicación (y no a la carpeta genérica External). Para ello:
    - En la barra superior de VS Code, ve a File > Open Folder.
    - Navega hasta /External/nombre-del-proyecto y ábrela.
    - Verifica que el Explorador de archivos (lateral izquierdo) muestre únicamente el contenido de tu aplicación (archivos .cpp, CMakeLists.txt, etc.).

#### 3. Selecciona los ajustes de la barra superior de busqueda
- Selecciona previamente [Scan For Kits]
- Y luego selecciona el compilador GCC 11.4.0 aarch64-linux -gnu


>  **Nota:** Importante: Si abres únicamente la carpeta External, las tareas de compilación y depuración no encontrarán el ejecutable ni la configuración correcta y, por tanto, fallarán.


## 5. Ejecución y depuración desde VS Code

1. **Botón “Run” en la barra de estado inferior**

   - Con la carpeta correcta seleccionada, haz clic en el icono de reproducción ▶ (“Run”) que aparece en la parte inferior de la barra de estado.
   - Esto ejecutará la configuración predeterminada para tu proyecto (por ejemplo, “Run hl”) según esté definida en `launch.json`.

2. **Ejecutar con F5 o con el icono de Debugging**

   - Alternativamente, pulsa **F5** o usa el icono de **Start Debugging**, previamente acuerdate de seleccionar un breakpoint para iniciar el depurador.
   - VS Code lanzará el depurador según la definición en `launch.json`:
     - Compilará automáticamente (preLaunchTask = “CMake Build”).
     - Iniciará GDB y se detendrá en el primer punto de interrupción (si has marcado algún breakpoint).

4. **Ejecución manual en terminal**
    - Si prefieres no usar el depurador integrado, puedes seguir trabajando en la terminal integrada (pulsa <kbd>Ctrl</kbd>+<kbd>`</kbd>).
    - Desde `/External/nombre-del-proyecto/`, ejecuta:
     ```bash
     mpirun -np 4 /home/hl-user/External/hl-bin/hl<nombre-del-proyecto>
     ```
    - Ajusta `-np 4` según el número de procesos MPI que necesites.



## 6. Detener o reiniciar el contenedor

  1. Abre **Remote Explorer** en la barra lateral (ícono de monitor con flecha).

2. En la sección **Dev Containers**, localiza tu contenedor (por ejemplo, `docker-hiperlife-container-1`).

3. Haz clic en el icono X (“Remove Container”) junto a su nombre:
   - Esto parará el contenedor y lo eliminará de la lista.
   - Si deseas volver a desarrollarlo, selecciona tu imagen Docker (por ejemplo, `hiperlife-dev:latest`) 

  > **Nota:** Detener el contenedor no elimina la imagen, por lo que tus cambios en `/External/nombre-del-proyecto` persistirán mientras no borres manualmente la carpeta o la imagen Docker.
