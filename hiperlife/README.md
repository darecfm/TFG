# Entorno de Desarrollo para hiperlife con Docker

Este sistema prepara un contenedor completamente funcional para desarrollar y compilar proyectos basados en hiperlife, sin necesidad de realizar pasos manuales adicionales.

---

## ¿Qué hace cada archivo?

### `docker-compose.yaml`
- Levanta el servicio principal `hiperlife-container` a partir de la imagen lista para desarrollar.
- Monta el volumen `External/`, que persiste el código fuente y los binarios entre el contenedor y tu máquina local.
- Define variables de entorno (`PROJECT_NAME`, `DEBUG_MODE`, `NUM_THREADS`, etc.) sin necesidad de modificar el contenedor.
- Ejecuta automáticamente el script de inicialización `initHL.sh` al arrancar el contenedor.

### `Dockerfile-app`
- Extiende la imagen base de HiperLife con herramientas útiles como `gdb`.
- Preconfigura rutas y variables de entorno estándar.
- Copia y da permisos al script de inicialización.
- Deja el contenedor en modo interactivo (`CMD ["/bin/bash"]`) para que puedas seguir trabajando dentro del entorno.

### `initHL.sh`
- Automatiza la preparación del entorno de desarrollo.
- Si el proyecto definido por `PROJECT_NAME` no existe, copia una plantilla base desde el contenedor.
- Crea todas las carpetas necesarias para compilar e instalar el binario.
- Ejecuta `CMake` con las opciones adecuadas, controladas por variables como `ENABLE_TESTS`, `ENABLE_EXAMPLES`, etc.
- Instala el binario compilado en el volumen compartido listo para ser ejecutado o depurado.

### `.env`
- Este archivo permite personalizar fácilmente los parámetros de compilación y desarrollo del entorno Docker **sin editar los archivos internos del proyecto**.  
- Los valores definidos aquí se utilizan automáticamente por `.env` y `docker-compose.yaml` para configurar el contenedor al levantarlo con caracteristicas predefinidas.


---

## Ventajas del sistema

- **Portabilidad total**: No necesitas instalar dependencias en tu máquina local. Todo funciona dentro del contenedor.
- **Persistencia**: Código y binarios se almacenan en `External/`, accesibles desde fuera y dentro del contenedor.
- **Automatización simple**: Todo se configura y compila automáticamente al levantar el contenedor.
- **Personalización**: Puedes modificar `.env` o `docker-compose.yaml` para cambiar variables del entorno.
- **Interactividad**: Accede al entorno con `docker compose exec` y sigue trabajando con herramientas adicionales si lo necesitas.

---

## Notas adicionales

- El volumen `External/` permite mantener múltiples proyectos activos y compartir binarios entre sesiones.
- Puedes definir nuevas variables de entorno para ajustar flags de compilación.
- Para iniciar un nuevo proyecto, simplemente cambia el valor de `PROJECT_NAME` y se configurará automáticamente.