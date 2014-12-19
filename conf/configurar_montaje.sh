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
		PUNTO_MONTAJE=$linea
	else
		echo "Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let C+=1
done
IFS=$oldIFS
#Editamos el fichero fstab para hacer los cambios persistentes
`mount $NOMBRE $PUNTO_MONTAJE` && echo "#Device: $NOMBRE" >> /etc/fstab && echo "$NOMBRE $PUNTO_MONTAJE auto defaults,auto,rw 0 0" >> /etc/fstab || echo "Error al montar el dispositivo"
