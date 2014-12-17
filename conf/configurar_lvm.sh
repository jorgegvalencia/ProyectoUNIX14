#!/bin/bash

#Recopilamos la informacion del fichero de perfil del servicio
oldIFS=$IFS
IFS=$'\n'
C=0
for linea in $(cat $1); do
	if [ $C = 0 ]; then
		#Nombre del grupo de volumenes
		NOMBRE=$linea
	elif [ $C = 1 ]; then
		#Lista de dispositivos
		DISPOSITIVOS_AUX=$linea
	elif [ $C >= 2 ]; then
		#Volumenes
		VOLUMENES_AUX[$(($C-2))]=$linea
	else
		echo "Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let C+=1
done
IFS=$' '
read -a DISPOSITIVOS <<< "$DISPOSITIVOS_AUX"

#Numero de dispositivos = ${#DISPOSITIVOS[*]}
#Dispositivo i = S{DISPOSITIVOS[i]}

#Numero de volumenes = ${#VOLUMENES_AUX[*]}
# Para cada uno hacer:
# read -a VOLUMEN <<< "${VOLUMENES_AUX[i]}"
# NOMBRE_VOL = ${VOLUMEN[0]}
# TAMAÑO_VOL = ${VOLUMEN[1]}

IFS=$oldIFS