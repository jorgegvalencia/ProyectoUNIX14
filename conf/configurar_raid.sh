#!/bin/bash

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

#Instalar la herramienta mdadm
echo "Preparando configuración del RAID $NOMBRE Nivel $NIVEL"
echo "Instalando mdadm..."
# Fuente: http://serverfault.com/questions/578068/install-mdadm-without-user-input-in-wheezy
export DEBIAN_FRONTEND=noninteractive
apt-get -y install mdadm --no-install-recommends >> /dev/null && echo "Servicio mdadm instalado"
#Montar el RAID y guardar la configuración
echo "Creando raid..."
mdadm --create -R --name=$NOMBRE --level=$NIVEL --raid-devices=${#DISPOSITIVOS[*]} $NOMBRE $DISPOSITIVOS_AUX
