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
    echo "CONFIG: Error en el formato del fichero de perfil del servicio"
    exit 1
fi
IFS=$oldIFS

#Instalamos los paquetes necesarios
apt-get -y update > /dev/null 2>&1 && echo "CONFIG: Actualizando paquetes..."
export DEBIAN_FRONTEND=noninteractive
echo "CONFIG: Instalando nfs-common..."
apt-get -y install nfs-common --no-install-recommends > /dev/null
echo "CONFIG: Instalando nfs-kernel-server..."
apt-get -y install nfs-kernel-server --no-install-recommends > /dev/null
echo "CONFIG: Configurando servidor nfs..."
for DIR in ${DIRECTORIOS[*]}; do
    echo "$DIR *(rw,sync)" >> /etc/exports
done
echo "CONFIG: Configuración del servidor nfs completada"