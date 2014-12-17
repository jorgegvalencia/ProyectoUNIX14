#!/bin/bash

#Recopilamos la informacion del fichero de perfil del servicio
oldIFS=$IFS
IFS=$'\n'
C=0
for linea in $(cat $1); do
	if [ $C = 0 ]; then
		#Directorio
		DIRECTORIO=$linea
	elif [ $C = 1 ]; then
		#Direccion del servidor
		DIR_SERVER=$linea
	elif [ $C = 2 ]; then
		#Directorio destino del Backup
		DESTINO=$linea
	elif [ $C = 3 ]; then
		#Perioricidad en horas
		HORAS=$linea
	else
		echo "Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let C+=1
done
IFS=$oldIFS