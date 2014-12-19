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
		echo "$NIVEL"
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

echo "Creando raid"
#Instalar el servicio
apt-get -y install mdadm > /dev/null && echo "Servicio mdadm instalado"
#Montar el RAID y guardar configuracion del RAID
mdadm --create -R --name=$NOMBRE --level=$NIVEL --raid-devices=${#DISPOSITIVOS[*]} $NOMBRE $DISPOSITIVOS_AUX 2> /dev/null  && mdadm --detail $NOMBRE --brief >> /etc/mdadm/mdadm.conf && echo "El RAID "$NOMBRE" de nivel "$NIVEL" ha sido creado con exito" || echo "Error: fallo en la creacion del RAID"
