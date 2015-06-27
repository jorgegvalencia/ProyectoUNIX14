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

#Fichero de configuración sin líneas no válidas (# y blancas)
CONFIG=`grep -v '[[:blank:]]*#' $1 | grep '[[:blank:]]'`

#Comprobar numero de parametros correctos en fichero de configuración
services="mount raid lvm nis_server nis_client nfs_server nfs_client backup_server backup_client"
IFS=$'\n'
LINE=0
for arg in $CONFIG; do
	IFS=$' '
	#echo $arg
	let LINE+=1
	C=0
	for word in $arg; do
		LINEA[$C]=$word
		if [ $C -eq 1 ]; then
			#fuente: http://askubuntu.com/questions/299710/how-to-determine-if-a-string-is-a-substring-of-another-in-bash
			if [ "${services/ ${LINEA[$C]} }" = "$services" ]; then
				echo "CONFIG: Error en línea $LINE. El servicio \"${LINEA[$C]}\" no es válido. Abortando..."
				exit 1
			fi
		elif [ $C -eq 2 ]; then
			if [ ! -f ${LINEA[$C]} ]; then
				echo "CONFIG: El fichero de perfil de configuración \"${LINEA[$C]}\" no se encuentra disponible. Abortando..."
				exit 1
			fi
		fi
		let C+=1
	done
	IFS=$'\n'
	if [ ${#LINEA[*]} -ne 3 ]; then
		echo "CONFIG: Error en el fichero de configuración. Número de parámetros incorrectos (${#LINEA[*]}) en la línea $LINE" 
		exit 1
	fi
	LINEA=()
done

CONFIG=`grep -v '[[:blank:]]*#' $1 | grep '[[:blank:]]'`

#Contador = 0 (Máquina destino)
#Contador = 1 (Nombre servicio)
#Contador = 2 (Fichero perfil configuración)
#C=0
IFS=$'\n'
for arg in $CONFIG; do
	IFS=$' '
	read -a LINEA <<< $arg 
	IFS=$'\n'
		#Máquina destino
		MAQUINA=${LINEA[0]}
		#Nombre servicio
		SERVICIO=${LINEA[1]}
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
		*)
			echo "CONFIG: Error en el servicio indicado ($SERVICIO). Abortando..."
			exit 1
			;;
		esac
		#Ruta del fichero perfil configuración
		FCONF=${LINEA[2]}
		echo 'CONFIG: Fichero de perfil de configuración: '$FCONF
		#Creamos el directorio temporal donde situaremos los ficheros de configuración
		echo 'CONFIG: Preparando archivos...'
		ssh root@$MAQUINA 'mkdir ~/ASI2014/' > /dev/null 2>&1 || { echo "CONFIG: No es posible establecer conexion con la máquina. Abortando" ; exit 1; }
		scp $FCONF root@$MAQUINA:~/ASI2014/$FCONF > /dev/null 2>&1
		scp ./conf/$SCRIPT root@$MAQUINA:~/ASI2014/$SCRIPT > /dev/null 2>&1
		#Ejecutamos el servicio
		ssh root@$MAQUINA "chmod +x ~/ASI2014/$SCRIPT" > /dev/null 2>&1
		ssh root@$MAQUINA "~/ASI2014/$SCRIPT ~/ASI2014/$FCONF" 2>&1
		#Eliminamos los ficheros de configuración temporales utilizados
		ssh root@$MAQUINA 'rm -r ~/ASI2014/' > /dev/null 2>&1
done