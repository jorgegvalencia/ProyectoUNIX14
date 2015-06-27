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
		echo "CONFIG: Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let C+=1
done
IFS=$oldIFS
export DEBIAN_FRONTEND=noninteractive
echo "CONFIG: Instalando NIS..."
apt-get -y install nis >> /dev/null
echo "CONFIG: Configurando cliente NIS..."
echo "`sed s/"NISCLIENT=false"/"NISCLIENT=true"/g /etc/default/nis`" > /etc/default/nis
echo "
# yp.conf       Configuration file for the ypbind process. You can define
#               NIS servers manually here if they can't be found by
#               broadcasting on the local net (which is the default).
#
#               See the manual page of ypbind for the syntax of this file.
#
# IMPORTANT:    For the "ypserver", use IP addresses, or make sure that
#               the host is in /etc/hosts. This file is only interpreted
#               once, and if DNS isn't reachable yet the ypserver cannot
#               be resolved and ypbind won't ever bind to the server.

# ypserver ypserver.network.com
domain $DOMINIO server $SERVIDOR" > /etc/yp.conf

echo "`sed s/"passwd:[[:blank:]]*compat"/"passwd: \tnis compat"/g /etc/nsswitch.conf`" > /etc/nsswitch.conf
echo "`sed s/"group:[[:blank:]]*compat"/"group: \tnis compat"/g /etc/nsswitch.conf`" > /etc/nsswitch.conf
echo "`sed s/"shadow:[[:blank:]]*compat"/"shadow: \tnis compat"/g /etc/nsswitch.conf`" > /etc/nsswitch.conf
#/etc/init.d/nis start