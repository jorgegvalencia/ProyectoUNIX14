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
#CONFIG=`grep -v '[[:blank:]]*#' $1 | grep '[[:blank:]]'`

#Se analiza cada palabra del fichero de configuración ($1)
for arg in $(cat $1); do
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
		#Ruta del fichero perfil configuración
		FCONF=$arg
		oldIFS=$IFS
		IFS=$'/'
		read -a FNAME_AUX <<< "$FCONF"
		IFS=$oldIFS
		N=${#FNAME_AUX[*]}
		#Nombre del fichero
		FNAME=${FNAME_AUX[$(($N-1))]}
		#Creamos el directorio donde alojaremos los ficheros en la máquina
		ssh $MAQUINA mkdir /ASI2014
		case $SERVICIO in
		mount )
			#Copiamos archivos a la máquina
			scp ./conf/configurar_montaje.sh root@$MAQUINA:/ASI2014/ >> /dev/null
			scp $FCONF root@$MAQUINA:/ASI2014/ >> /dev/null
			#Ejecutamos el servicio
			ssh $MAQUINA chmod +x /ASI2014/configurar_montaje.sh
			ssh $MAQUINA /ASI2014/configurar_montaje.sh /ASI2014/$FNAME
			;;
		raid )
			#Copiamos archivos a la máquina
			scp ./conf/configurar_raid.sh root@$MAQUINA:/ASI2014/ >> /dev/null
			scp $FCONF root@$MAQUINA:/ASI2014/ >> /dev/null
			#Ejecutamos el servicio
			ssh $MAQUINA chmod +x /ASI2014/configurar_raid.sh
			ssh $MAQUINA /ASI2014/configurar_raid.sh /ASI2014/$FNAME
			;;
		lvm )
			#Copiamos archivos a la máquina
			scp ./conf/configurar_lvm.sh root@$MAQUINA:/ASI2014/ >> /dev/null
			scp $FCONF root@$MAQUINA:/ASI2014/ >> /dev/null
			#Ejecutamos el servicio
			ssh $MAQUINA chmod +x /ASI2014/configurar_lvm.sh
			ssh $MAQUINA /ASI2014/configurar_lvm.sh /ASI2014/$FNAME
			;;
		nis_server )
			#Copiamos archivos a la máquina
			scp ./conf/configurar_nis_server.sh root@$MAQUINA:/ASI2014/ >> /dev/null
			scp $FCONF root@$MAQUINA:/ASI2014/ >> /dev/null
			#Ejecutamos el servicio
			ssh $MAQUINA chmod +x /ASI2014/configurar_nis_server.sh
			ssh $MAQUINA /ASI2014/configurar_nis_server.sh /ASI2014/$FNAME
			;;
		nis_client )
			#Copiamos archivos a la máquina
			scp ./conf/configurar_nis_client.sh root@$MAQUINA:/ASI2014/ >> /dev/null
			scp $FCONF root@$MAQUINA:/ASI2014/ >> /dev/null
			#Ejecutamos el servicio
			ssh $MAQUINA chmod +x /ASI2014/configurar_nis_client.sh
			ssh $MAQUINA /ASI2014/configurar_nis_client.sh /ASI2014/$FNAME
			;;
		nfs_server )
			#Copiamos archivos a la máquina
			scp ./conf/configurar_nfs_server.sh root@$MAQUINA:/ASI2014/ >> /dev/null
			scp $FCONF root@$MAQUINA:/ASI2014/ >> /dev/null
			#Ejecutamos el servicio
			ssh $MAQUINA chmod +x /ASI2014/configurar_nfs_server.sh
			ssh $MAQUINA /ASI2014/configurar_nfs_server.sh /ASI2014/$FNAME
			;;
		nfs_client )
			#Copiamos archivos a la máquina
			scp ./conf/configurar_nfs_client.sh root@$MAQUINA:/ASI2014/ >> /dev/null
			scp $FCONF root@$MAQUINA:/ASI2014/ >> /dev/null
			#Ejecutamos el servicio
			ssh $MAQUINA chmod +x /ASI2014/configurar_nfs_client.sh
			ssh $MAQUINA /ASI2014/configurar_nfs_client.sh /ASI2014/$FNAME
			;;
		backup_server )
			#Copiamos archivos a la máquina
			scp ./conf/configurar_backup_server.sh root@$MAQUINA:/ASI2014/ >> /dev/null
			scp $FCONF root@$MAQUINA:/ASI2014/ >> /dev/null
			#Ejecutamos el servicio
			ssh $MAQUINA chmod +x /ASI2014/configurar_backup_server.sh
			ssh $MAQUINA /ASI2014/configurar_backup_server.sh /ASI2014/$FNAME
			;;
		backup_client )
			#Copiamos archivos a la máquina
			scp ./conf/configurar_backup_client.sh root@$MAQUINA:/ASI2014/ >> /dev/null
			scp $FCONF root@$MAQUINA:/ASI2014/ >> /dev/null
			#Ejecutamos el servicio
			ssh $MAQUINA chmod +x /ASI2014/configurar_backup_client.sh
			ssh $MAQUINA /ASI2014/configurar_backup_client.sh /ASI2014/$FNAME
			;;
		esac
		#Eliminamos todos los datos de la máquina
		ssh $MAQUINA rm -r /ASI2014
	else
		#Error
		echo 'Error al aumentar el contador'
		exit 1
	fi
	
	#Se incrementa el contador
	let C+=1
	let C%=3
	
done

