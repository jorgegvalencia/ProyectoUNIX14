#!/bin/bash

#Recopilamos la informacion del fichero de perfil del servicio
oldIFS=$IFS
IFS=$'\n'
C=0
for linea in $(cat $1); do
	if [ $C = 0 ]; then
		#Nombre del dispositivo
		NOMBRE=$linea
	elif [ $C = 1 ]; then
		#Punto de montaje
		NIVEL=$linea
	elif [ $C = 2 ]; then
		#Dispositivos
		DISPOSITIVOS_AUX=$linea
	else
		echo "Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let C+=1
done
IFS=$' '
read -a DISPOSITIVOS <<< "$DISPOSITIVOS_AUX"
IFS=$oldIFS

#Creamos el raid
mdadm --create --name=$NOMBRE -level=$NIVEL --raid-devices=${#DISPOSITIVOS[*]} $DISPOSITIVOS_AUX
