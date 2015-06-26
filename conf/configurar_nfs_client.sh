#!/bin/bash

#Recopilamos la informacion de fichero de perfil de servicio
oldIFS=$IFS
IFS=$'\n'
C=0
for linea in $(cat $1); do
    #Sistema de ficheros (dirRemoto + puntoMontaje)
    DIRECTORIOS[$C]=$linea
    let C+=1
done
if [ $C < 1 ]; then
    echo "Error en el formato del fichero de perfil del servicio"
    exit 1
fi

#Instalamos el paquete
export DEBIAN_FRONTEND=noninteractive
echo "Instalando nfs-common..."
apt-get -y install nfs-common --no-install-recommends > /dev/null
echo "Configurando cliente nfs..."
for SF in ${DIRECTORIOS[*]}; do
    echo "$SF nfs defaults,auto 0 0" >> /etc/fstab
done

IFS=$oldIFS

#Si hacen falta por separado:
# IFS=$' '
# read -a DIRECTORIOS <<< "$SF"
# DIR_REMOTO = ${DIRECTORIOS[0]}
# PUNTO_MONTAJE = ${DIRECTORIOS[1]}