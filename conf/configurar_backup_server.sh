#!/bin/bash

#Recopilamos la informacion del fichero de perfil del servicio
oldIFS=$IFS
IFS=$'\n'
C=0
for linea in $(cat $1); do
	if [ $C = 0 ]; then
		#Directorio Backup
		DIRECTORIO=$linea
	else
		echo "Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let C+=1
done
IFS=$oldIFS