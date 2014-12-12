#! /bin/bash

# Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "Uso: $0 <fichero_configuracion>"
	exit 1
fi

# Comprobar que se tienen los ficheros necesarios
scripts="configurar_montaje configurar_raid configurar_lvm configurar_nis_server configurar_nis_client configurar_nfs_server configurar_nfs_client configurar_backup_server configurar_backup_client"

for fich in $scripts; do
	if [ ! -f $fich ]
	then
		echo "El fichero "$fich" no se ha podido encontrar. Abortando ejecución"
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
		
		case $SERVICIO in
		mount )
			configurar_montaje $FCONF;;
		raid )
			configurar_raid $FCONF;;
		lvm )
			configurar_lvm $FCONF;;
		nis_server )
			configurar_nis_server $FCONF;;
		nis_client )
			configurar_nis_client $FCONF;;
		nfs_server )
			configurar_nfs_server $FCONF;;
		nfs_client )
			configurar_nfs_client $FCONF;;
		backup_server )
			configurar_backup_server $FCONF;;
		backup_client )
			configurar_backup_client;;
		;;
		esac

		#Comienzo del servicio
		
		#Fin del servicio
		
	else
		#Error
		echo 'Error al aumentar el contador'
		exit(1)
	fi
	
	#Se incrementa el contador
	let C+=1
	let C%=3
	
done