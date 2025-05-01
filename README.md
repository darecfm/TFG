# TFG
---

## **Pasos para crear la imagen Docker de HiperLife**

---

**1. Asegúrate de tener:**

En tu carpeta ( tools/docker/):

```
├── Dockerfile-app         # Dockerfile personalizado
├── docker-compose.yaml     # Define el servicio del contenedor
├── initHL.sh               # Script de inicialización y compilación
```
----------

**2. Construye la imagen**

Desde la carpeta donde está  Dockerfile-app1, ejecuta:
```
docker build -t hiperlife-app -f Dockerfile-app .
```

•  hiperlife-app2: nombre de tu imagen personalizada, puedes poner el nombre que desees. Pero si la editas acuerdate de cambiar la imagen en el file docker-compose.yaml

•  Dockerfile-app1: tu archivo Dockerfile.

----------

**3. Levanta el contenedor**

  • Inicialización por defecto (utiliza "hl-base-project" como nombre del proyecto):
```
docker compose up 
```

  • Inicialización personalizada (el usuario define el nombre del proyecto):

```
PROJECT_NAME=nombre-del-proyecto docker compose up
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

**5. Finalizar Docker**

```
docker compose down      # Para parar y eliminar el contenedor
docker rmi hiperlife-app  # Para borrar la imagen si lo deseas
```

 
