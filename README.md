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
docker build -t darecfm/hiperlife-app:latest -f Dockerfile-app .
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
docker rmi darecfm/hiperlife-app:latest  # Para borrar la imagen si lo deseas
```

---
--------------
---
---

---
---
## **PASOS PARA PROBAR TU APP CON DOCKER + HIPERLIFE + VS CODE**
---

Para que todo funcione correctamente en tu entorno con Docker y Visual Studio Code, estas son las extensiones que debes tener instaladas antes de abrir el contenedor y trabajar con el proyecto Hiperlife:

**Extensiones necesarias en VS Code:**

1. Dev Containers

	•	ID: ms-vscode-remote.remote-containers

	•	Permite abrir entornos de desarrollo dentro de contenedores Docker directamente desde VS Code.


2. C/C++

   •	ID: ms-vscode.cpptools

	•	Habilita IntelliSense, depuración, y herramientas de compilación para C y C++.


Una vez instalado las nuevas extensiones nos dirijiremos a la parte izquierda en donde clicaremos en (remote Explorer), donde apareceran todas los dockers que tenemos habilitados y creados por lo que iremos:
```
Remote Explorer > Dev Containers > docker > docker-hiperlife-container-1 
```
Una vez localizemos nuestra maquina virtual, vemos que hay 3 iconos:
  Flecha: Attach in current window, donde accederemos con nuestra misma ventana al contenedor
  Ventana: Attach in new Window, que servirá para poder lanzarla en otra ventana aparte
  X: Remove container que servirá para eliminar nuestro contenedor


Una vez accediendo nos fijaremos que estemos dentro de la carpeta de nuestra aplicación como lo hallamos llamado, daremos al play que se encontrara en la parte superior derecha

Despues iremos a la parte inferior pulsaremos run hlPrueba01, en donde se nos abre la posibilidad no solamente de ejecutar dentro de nuestra aplicación sino de debugear