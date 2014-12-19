#!/bin/bash

#Recopilamos la informacion del fichero de perfil del servicio
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
apt-get install nfs-common >> /dev/null
apt-get install nfs-kernel-server >> /dev/null
for DIR in ${DIRECTORIOS[*]}; do
	echo "$DIR (rw)" >> /etc/exports
done
