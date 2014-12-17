#!/bin/bash

#Recopilamos la informacion del fichero de perfil del servicio
oldIFS=$IFS
IFS=$'\n'
C=0
for linea in $(cat $1); do
	#Sistema de ficheros (dirRemoto + puntoMontaje)
	DIRECTORIOS_AUX[$C]=$linea
	let C+=1
done
if [ $C < 1 ]; then
	echo "Error en el formato del fichero de perfil del servicio"
	exit 1
fi
IFS=$' '
#Numero de directorios = ${#DIRECTORIOS_AUX[*]}
# Para cada uno hacer:
# read -a DIRECTORIOS <<< "${DIRECTORIOS_AUX[i]}"
# DIR_REMOTO = ${DIRECTORIOS[0]}
# PUNTO_MONTAJE = ${DIRECTORIOS[1]}

IFS=$oldIFS