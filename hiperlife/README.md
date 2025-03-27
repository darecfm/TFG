# Configuración `docker-compose.yaml` 

Este archivo permite levantar el contenedor `hiperlife-container` con una configuración lista para desarrollar y compilar aplicaciones basadas en HiperLife.

- **Volumen único (`External`)**:
  Se monta un único volumen que contiene el código fuente, archivos de configuración y resultados de compilación. Esto simplifica el manejo de archivos y evita conflictos por sobrescritura entre contenedor y host.

- **Ejecución automática de `initHL.sh`**:
  El script `initHL.sh` es invocado automáticamente al arrancar el contenedor. Este se encarga de compilar el proyecto, configurar los entornos y dejarlo listo para trabajar.

- **Mantener el contenedor activo (`exec bash`)**:
  Una vez terminada la inicialización, se ejecuta un bash interactivo para que el usuario pueda seguir trabajando dentro del contenedor de forma manual si lo desea.

Esto permite que un usuario pueda comenzar a trabajar simplemente con `docker compose up`, sin necesidad de instalar dependencias localmente.

---


# Configuración Dockerfile-app1 


Este Dockerfile define la imagen `hiperlife-app2`, una extensión personalizada de la imagen base `hiperlife/hiperlife`, diseñada para compilar y ejecutar proyectos de HyperLife de manera modular, interactiva y persistente.

##  Detalles de configuración

###  Imagen base

```dockerfile
FROM hiperlife/hiperlife
```

Utiliza una imagen base ya preparada con dependencias científicas y bibliotecas necesarias.

---

###  Configuración del usuario y entorno

```dockerfile
USER hl-user
WORKDIR /home/hl-user
```

Define el usuario de ejecución por defecto y su entorno de trabajo.

---

### Clonación del proyecto

```dockerfile
RUN mkdir -p hl-src && cd hl-src && \
    git clone --branch dev https://gitlab.com/hiperlife/hl-base-project.git || true
```

Clona el repositorio si aún no existe. El operador `|| true` evita errores si ya fue clonado.

---

###  Configuración de entorno y estructura

```dockerfile
ENV HL_BASE_PATH=/home/hl-user/hl-bin
RUN mkdir -p /home/hl-user/bin
ENV PATH="${PATH}:/home/hl-user/bin"
```

Se configura una ruta estándar de instalación para HL y se añade al `PATH`.

---

###  Inclusión del script de inicialización

```dockerfile
COPY initHL.sh /home/hl-user/bin/initHL.sh
USER root
RUN chmod +x /home/hl-user/bin/initHL.sh
RUN apt-get update && apt-get install -y gdb
USER hl-user
```

- Se copia el script `initHL.sh` al contenedor.
- Se le da permiso de ejecución.
- Se instala `gdb` para depuración con VSCode.

---

###  Directorio y entrada por defecto

```dockerfile
WORKDIR /home/hl-user/
CMD ["/bin/bash"]
```

El contenedor se inicia en el entorno del usuario, con una shell lista para usarse.

---
---


##  Uso

```bash
docker build -t hiperlife-app2 -f Dockerfile-app1 .
docker compose up
```

> La compilación se hará automáticamente gracias al script `initHL.sh`.

La compilación del código no se hace durante la construcción de la imagen.  Se traslada al script `initHL.sh` y se ejecuta **al iniciar el contenedor** con `docker-compose`.