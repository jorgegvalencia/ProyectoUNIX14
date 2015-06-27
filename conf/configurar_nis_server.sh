#!/bin/bash

#Recopilamos la información del fichero de perfil del servicio
oldIFS=$IFS
IFS=$'\n'
C=0
for linea in $(cat $1); do
	if [ $C = 0 ]; then
		#Nomnre del dominio nis
		DOMINIO=$linea
	else
		echo "CONFIG: Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let C+=1
done
IFS=$oldIFS
apt-get -y update > /dev/null 2>&1 && echo "CONFIG: Actualizando paquetes..."
export DEBIAN_FRONTEND=noninteractive
echo "CONFIG: Instalando NIS..."
apt-get -y install nis --no-install-recommends >> /dev/null
echo "CONFIG: Configurando servidor NIS..."
echo $DOMINIO > /etc/defaultdomain && echo "CONFIG: Establecido nombre de dominio a \"$DOMINIO\""
echo "`sed s/"NISSERVER=false"/"NISSERVER=master"/g /etc/default/nis`" > /etc/default/nis
echo "`sed s/"NISCLIENT=true"/"NISCLIENT=false"/g /etc/default/nis`" > /etc/default/nis
echo "CONFIG: Configuración del servidor NIS completada"