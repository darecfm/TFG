#!/bin/bash

echo "Verificando si el código base ya existe en External..."

#si la carpeta del codigo no esta en external, la copiamos..
if [ ! -d "/home/hl-user/External/hl-base-project" ]; then
    echo "Copiando hl-base-project a External..."
    cp -r /home/hl-user/hl-src/hl-base-project /home/hl-user/External/
fi

echo " Configurando compilación en External..."
#crear el build antes de compilar 
mkdir -p /home/hl-user/External/hl-base-project/build
mkdir -p /home/hl-user/External/hl-bin
cd /home/hl-user/External/hl-base-project/build

#si no se ha compilado antes, lo compilamos esto hay que quitarlo 

    echo "⚙️  Compilando código fuente..."
    cmake .. -D CMAKE_INSTALL_PREFIX=/home/hl-user/External/hl-bin -D HL_BASE_PATH=/home/hl-user/hl-bin
    make install
    


echo " Inicialización completada"