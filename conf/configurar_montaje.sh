#!/bin/bash

#Recopilamos la informacion del fichero de perfil del servicio
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

#Comprobamos si la configuración ya esta en el fichero fstab
if ! grep -q "$NOMBRE[[:blank:]]*$PUNTO_MONTAJE[[:blank:]]*auto[[:blank:]]*defaults[[:blank:]]*,[[:blank:]]*auto[[:blank:]]*,[[:blank:]]*rw[[:blank:]]*0[[:blank:]]*0" /etc/fstab
then
	#Editamos el fichero fstab para hacer los cambios persistentes
	'mount $NOMBRE $PUNTO_MONTAJE' && echo "#Device: $NOMBRE" >> /etc/fstab && echo "$NOMBRE $PUNTO_MONTAJE auto defaults,auto,rw 0 0" >> /etc/fstab || echo "Error al montar el dispositivo"
fi

