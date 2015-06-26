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
		echo "Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let C+=1
done
IFS=$oldIFS
export DEBIAN_FRONTEND=noninteractive
echo "Instalando nis..."
apt-get -y install nis >> /dev/null
echo "Configurando servidor nis..."
echo $DOMINIO >> /etc/defaultdomain
echo "`sed s/"NISSERVER=false"/"NISSERVER=true"/g /etc/default/nis`" > /etc/default/nis
echo "`sed s/"NISCLIENT=true"/"NISCLIENT=false"/g /etc/default/nis`" > /etc/default/nis
#/usr/lib/yp/ypinit -m
#/etc/init.d/nis start