#!/bin/bash

#Recopilamos la informacion del fichero de perfil del servicio
oldIFS=$IFS
IFS=$'\n'
C=0
for linea in $(cat $1); do
	if [ $C = 0 ]; 	then
		#Nombre del grupo de volumenes
		NOMBRE=$linea
	elif [ $C = 1 ]; then
		#Lista de dispositivos
		DISPOSITIVOS=$linea
	elif [ $C > 1 ]; then
		#Volumenes
		VOLUMENES[$(($C-2))]=$linea
	else
		echo "CONFIG: Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let C+=1
done
IFS=$' '

#Instalamos el servicio
echo 'CONFIG: Instalando el servicio...'
export DEBIAN_FRONTEND=noninteractive
apt-get -y install lvm2 --no-install-recommends > /dev/null

#Inicializamos los volumenes fisicos
echo 'CONFIG: Inicializando volumenes fisicos...'
pvcreate $DISPOSITIVOS >> /dev/null

#Creamos el grupo
echo 'CONFIG: Creando el grupo...'
vgcreate $NOMBRE $DISPOSITIVOS >> /dev/null
IFS=$'\n'
#Creamos los volumenes logicos
echo 'CONFIG: Creando volumenes logicos...'
for item in ${VOLUMENES[*]}; do
        IFS=$' '
	read -a VOLUMEN <<< "$item"
	NOMBRE_VOL=${VOLUMEN[0]}
	SIZE_VOL=${VOLUMEN[1]}
	lvcreate --name $NOMBRE_VOL --size $SIZE_VOL $NOMBRE >> /dev/null && echo "CONFIG: Volumen $NOMBRE_VOL $SIZE_VOL creado" || echo "CONFIG: Fallo al crear el volúmen $NOMBRE_VOL"
done

IFS=$oldIFS
