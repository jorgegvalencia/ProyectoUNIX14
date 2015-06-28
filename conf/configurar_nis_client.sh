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
apt-get -y update > /dev/null 2>&1 && echo "CONFIG: Actualizando paquetes..."
export DEBIAN_FRONTEND=noninteractive
echo "CONFIG: Instalando NIS..."
apt-get -y install nis --no-install-recommends > /dev/null
echo "CONFIG: Configurando cliente NIS..."
echo $DOMINIO > /etc/defaultdomain
echo "domain $DOMINIO server $SERVIDOR" >> /etc/yp.conf
echo "ypserver $SERVIDOR" >> /etc/yp.conf
echo "`sed s/"NISCLIENT=false"/"NISCLIENT=true"/g /etc/default/nis`" > /etc/default/nis
echo "`sed s/"passwd:[[:blank:]]*compat"/"passwd: \tfiles nis"/g /etc/nsswitch.conf`" > /etc/nsswitch.conf
echo "`sed s/"group:[[:blank:]]*compat"/"group: \tfiles nis"/g /etc/nsswitch.conf`" > /etc/nsswitch.conf
echo "`sed s/"shadow:[[:blank:]]*compat"/"shadow: \tfiles nis"/g /etc/nsswitch.conf`" > /etc/nsswitch.conf
/etc/init.d/nis restart