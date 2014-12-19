#!/bin/bash

# Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "Uso: $0 <fichero_configuracion>"
	exit 1
fi

# Comprobar que se tienen los ficheros necesarios
scripts="configurar_montaje.sh configurar_raid.sh configurar_lvm.sh configurar_nis_server.sh configurar_nis_client.sh configurar_nfs_server.sh configurar_nfs_client.sh configurar_backup_server.sh configurar_backup_client.sh"

for fich in $scripts; do
	if [ ! -f ./conf/$fich ]
	then
		echo "El fichero ./conf/"$fich" no se ha podido encontrar. Abortando ejecución"
		exit 1
	fi
done

#Contador = 0 (Máquina destino)
#Contador = 1 (Nombre servicio)
#Contador = 2 (Fichero perfil configuración)
C=0

# Fichero de configuracion sin lineas no validas (# y blancas)
CONFIG=`grep -v '[[:blank:]]*#' $1 | grep '[[:blank:]]'`

#Se analiza cada palabra del fichero de configuración ($1)
for arg in $($CONFIG); do
	if [ $C = 0 ];
	then
		#Máquina destino
		MAQUINA=$arg
		
	elif [ $C = 1 ];
	then
		#Nombre servicio
		SERVICIO=$arg
		
	elif [ $C = 2 ];
	then
		#Fichero perfil configuración
		FCONF=$arg
		#Creamos el directorio donde alojaremos los ficheros en la máquina
		ssh $MAQUINA 'mkdir /ASI2014'
		case $SERVICIO in
		mount )
			scp ./conf/configurar_montaje.sh root@$MAQUINA:/ASI2014/
			scp $FCONF root@$MAQUINA:/ASI2014/
			ssh $MAQUINA '/ASI2014/configurar_montaje.sh $FCONF' < /dev/null
			;;
		#	`ssh $MAQUINA 'sh -s' < ./conf/configurar_montaje.sh`;;
		raid )
			scp ./conf/configurar_raid.sh root@$MAQUINA:/ASI2014/
			scp $FCONF root@$MAQUINA:/ASI2014/
			ssh $MAQUINA '/ASI2014/configurar_raid.sh $FCONF' < /dev/null
			;;
		lvm )
			scp ./conf/configurar_lvm.sh root@$MAQUINA:/ASI2014/
			scp $FCONF root@$MAQUINA:/ASI2014/
			ssh $MAQUINA '/ASI2014/configurar_lvm.sh $FCONF' < /dev/null
			;;
		nis_server )
			scp ./conf/configurar_nis_server.sh root@$MAQUINA:/ASI2014/
			scp $FCONF root@$MAQUINA:/ASI2014/
			ssh $MAQUINA '/ASI2014/configurar_nis_server.sh $FCONF' < /dev/null
			;;
		nis_client )
			scp ./conf/configurar_nis_client.sh root@$MAQUINA:/ASI2014/
			scp $FCONF root@$MAQUINA:/ASI2014/
			ssh $MAQUINA '/ASI2014/configurar_nis_client.sh $FCONF' < /dev/null
			;;
		nfs_server )
			scp ./conf/configurar_nfs_server.sh root@$MAQUINA:/ASI2014/
			scp $FCONF root@$MAQUINA:/ASI2014/
			ssh $MAQUINA '/ASI2014/configurar_nfs_server.sh $FCONF' < /dev/null
			;;
		nfs_client )
			scp ./conf/configurar_nfs_client.sh root@$MAQUINA:/ASI2014/
			scp $FCONF root@$MAQUINA:/ASI2014/
			ssh $MAQUINA '/ASI2014/configurar_nfs_client.sh $FCONF' < /dev/null
			;;
		backup_server )
			scp ./conf/configurar_backup_server.sh root@$MAQUINA:/ASI2014/
			scp $FCONF root@$MAQUINA:/ASI2014/
			ssh $MAQUINA '/ASI2014/configurar_backup_server.sh $FCONF' < /dev/null
			;;
		backup_client )
			scp ./conf/configurar_backup_client.sh root@$MAQUINA:/ASI2014/
			scp $FCONF root@$MAQUINA:/ASI2014/
			ssh $MAQUINA '/ASI2014/configurar_backup_client.sh $FCONF' < /dev/null
			;;
		;;
		esac
		#Eliminamos todos los datos de la máquina
		ssh $MAQUINA 'rm -r /ASI2014'
	else
		#Error
		echo 'Error al aumentar el contador'
		exit 1
	fi
	
	#Se incrementa el contador
	let C+=1
	let C%=3
	
done

