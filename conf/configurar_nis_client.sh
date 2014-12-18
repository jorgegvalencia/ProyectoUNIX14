#!/bin/bash

#Recopilamos la informacion del fichero de perfil del servicio
oldIFS=$IFS
IFS=$'\n'
C=0
for linea in $(cat $1); do
	if [ $C = 0 ]; then
		#Nombre del dominio nis
		DOMINIO=$linea
	elif [ $C = 1 ]; then
		#Servidor nis al que se desea conectar
		SERVIDOR=$linea
	else
		echo "Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let C+=1
done
IFS=$oldIFS

apt-get -y install nis >> /dev/null
echo "`sed s/"NISCLIENT=false"/"NISCLIENT=true"/g /etc/default/nis`" > /etc/default/nis
echo "domain $DOMINIO server $SERVIDOR" >> /etc/yp.conf
/etc/init.d/nis start