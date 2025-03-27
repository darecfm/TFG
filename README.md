# TFG

#### Configuración `docker-compose.yaml` 

Este archivo permite levantar el contenedor `hiperlife-container` con una configuración lista para desarrollar y compilar aplicaciones basadas en HiperLife.

- **Volumen único (`External`)**:
  Se monta un único volumen que contiene el código fuente, archivos de configuración y resultados de compilación. Esto simplifica el manejo de archivos y evita conflictos por sobrescritura entre contenedor y host.

- **Ejecución automática de `initHL.sh`**:
  El script `initHL.sh` es invocado automáticamente al arrancar el contenedor. Este se encarga de compilar el proyecto, configurar los entornos y dejarlo listo para trabajar.

- **Mantener el contenedor activo (`exec bash`)**:
  Una vez terminada la inicialización, se ejecuta un bash interactivo para que el usuario pueda seguir trabajando dentro del contenedor de forma manual si lo desea.

Esto permite que un usuario pueda comenzar a trabajar simplemente con `docker compose up`, sin necesidad de instalar dependencias localmente.
