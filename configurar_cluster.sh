#!/bin/bash

#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "Uso: $0 <fichero_configuracion>"
	exit 1
fi

#Comprobar que se tienen los ficheros necesarios
scripts="configurar_montaje.sh configurar_raid.sh configurar_lvm.sh configurar_nis_server.sh configurar_nis_client.sh configurar_nfs_server.sh configurar_nfs_client.sh configurar_backup_server.sh configurar_backup_client.sh"

for fich in $scripts; do
	if [ ! -f ./conf/$fich ]
	then
		echo "El fichero ./conf/"$fich" no esta disponible. Abortando ejecución."
		exit 1
	fi
done

#Contador = 0 (Máquina destino)
#Contador = 1 (Nombre servicio)
#Contador = 2 (Fichero perfil configuración)
C=0

#Fichero de configuración sin líneas no válidas (# y blancas)
CONFIG=`grep -v '[[:blank:]]*#' $1 | grep '[[:blank:]]'`

for arg in $CONFIG; do
	if [ $C = 0 ];
	then
		#Máquina destino
		MAQUINA=$arg
	elif [ $C = 1 ];
	then
		#Nombre servicio
		SERVICIO=$arg
		case $SERVICIO in
		mount )
			SCRIPT=configurar_montaje.sh
			;;
		raid )
			SCRIPT=configurar_raid.sh
			;;
		lvm )
			SCRIPT=configurar_lvm.sh
			;;
		nis_server )
			SCRIPT=configurar_nis_server.sh
			;;
		nis_client )
			SCRIPT=configurar_nis_client.sh
			;;
		nfs_server )
			SCRIPT=configurar_nfs_server.sh
			;;
		nfs_client )
			SCRIPT=configurar_nfs_client.sh
			;;
		backup_server )
			SCRIPT=configurar_backup_server.sh
			;;
		backup_client )
			SCRIPT=configurar_backup_client.sh
			;;
		esac
	elif [ $C = 2 ];
	then
		#Ruta del fichero perfil configuración
		FCONF=$arg
		echo 'Fichero de perfil de configuración: '$FCONF
		#Creamos el directorio temporal donde situaremos los ficheros de configuración
		echo 'Preparando archivos...'
		ssh root@$MAQUINA 'mkdir ~/ASI2014/' > /dev/null
		scp $FCONF root@$MAQUINA:~/ASI2014/$FCONF > /dev/null
		scp ./conf/$SCRIPT root@$MAQUINA:~/ASI2014/$SCRIPT > /dev/null
		#Ejecutamos el servicio
		echo 'Configurando servicio...'
		ssh root@$MAQUINA "chmod +x ~/ASI2014/$SCRIPT" > /dev/null
		ssh root@$MAQUINA "~/ASI2014/$SCRIPT ~/ASI2014/$FCONF" > /dev/null
		#Eliminamos los ficheros de configuración temporales utilizados
		ssh root@$MAQUINA 'rm -r ~/ASI2014/' > /dev/null
	else
		#Error
		echo 'ERROR en el fichero de configuración: Formato incorrecto.'
	fi
	#Se aumenta el contador y se calcula el módulo
	let C+=1
	let C%=3
done

