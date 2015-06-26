#!/bin/bash

#Recopilamos la informacion de fichero de perfil de servicio
oldIFS=$IFS
IFS=$'\n'
C=0
for linea in $(cat $1); do
    #Nombre del dominio
    DIRECTORIOS[$C]=$linea
    let C+=1
done
if [ $C < 1 ]; then
    echo "Error en el formato del fichero de perfil del servicio"
    exit 1
fi
IFS=$oldIFS

#Instalamos los paquetes necesarios
export DEBIAN_FRONTEND=noninteractive
echo "Instalando nfs-common..."
apt-get -y install nfs-common --no-install-recommends > /dev/null
echo "Instalando nfs-kernel-server..."
apt-get -y install nfs-kernel-server --no-install-recommends > /dev/null
echo "Configurando servidor nfs..."
for DIR in ${DIRECTORIOS[*]}; do
    echo "$DIR *(rw,sync)" >> /etc/exports
done
echo "Configuración del servidor nfs completada"