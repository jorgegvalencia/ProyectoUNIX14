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
export DEBIAN_FRONTEND=noninteractive
echo "CONFIG: Instalando NIS..."
apt-get -y install nis >> /dev/null
echo "CONFIG: Configurando servidor NIS..."
echo $DOMINIO >> /etc/defaultdomain
echo "`sed s/"NISSERVER=false"/"NISSERVER=true"/g /etc/default/nis`" > /etc/default/nis
echo "`sed s/"NISCLIENT=true"/"NISCLIENT=false"/g /etc/default/nis`" > /etc/default/nis
/usr/lib/yp/ypinit -m > /dev/null
echo "CONFIG: Configuración del servidor NIS completada"
#/etc/init.d/nis start