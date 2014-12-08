script configurar_cluster.sh

Procedimiento:

El administrador inicia sesión en cualquiera de las máquinas de la red.

El administrador prepara un fichero de configuración del cluster, indicando qué
servicios se deben instalar en cada máquina.

El administrador ejecuta el script configurar_cluster.sh, pasándole el fichero de configuración del cluster como parámetro.

El script se irá conectando por ssh a cada una de las máquinas especificadas e instalando y configurando los servicios indicados.

	./configurar_cluster.sh fichero_configuracion

fichero_configuracion:

Se ignoran las líneas en blanco y las que comiencen por #.
Las líneas de configuración siguen el formato:

	máquina-destino nombre-del-servicio fichero-de-perfil-de-servicio

Las líneas erróneas se deben reportar y śe deberá parar la ejecución del script.

máquina-destino: Nombre o dirección IP
nombre-del-servicio: Servicio a instalar/configurar
fichero-de-perfil-de-servicio: Fichero de configuración adicional con los parámetros del servicio que se desea configurar

	# Maquina servidora
	192.168.0.1 raid raid.conf
	192.168.0.1 mount mount_raid.conf
	192.168.0.1 nfs_server nfs_server.conf

	# Maquinas cliente
	192.168.0.2 nfs_client nfs_client.conf
	192.168.0.3 nfs_client nfs_client.conf
	192.168.0.4 nfs_client nfs_client.conf
	192.168.0.5 nfs_client nfs_client.conf

Servicios:

- Montaje

	mount
	fichero /etc/fstab	

	# /etc/fstab: static file system information.
	#
	# <file system> <mount point>   <type>  <options>       <dump>  <pass>
	
	Formato de fichero-de-perfil-de-servicio: [2]
	
	nombre-del-dispositivo
	punto-de-montaje

	VAR DEVICE = nombre-del-dispositivo
	VAR MOUNTPOINT = punto-de-montaje

	'echo "#File system: $DEVICE" >> /etc/fstab'
	'echo "$DEVICE $MOUNTPOINT auto defaults,auto,rw 0 0" >> /etc/fstab'

- RAID

	raid
	servicio mdadm
	fichero /etc/mdadm/mdadm.conf

	Formato de fichero-de-perfil-de-servicio: [2+]

	nombre-del-nuevo-dispositivo-raid
	nivel-de-raid
	dispositivo-1 [dispositivo-2 ...]

	/dev/md0
	1
	/dev/sdb1 /dev/sdc1

	VAR RAIDNAME = nombre-del-nuevo-dispositivo-raid
	VAR RAIDLEVEL = nivel-de-raid
	VAR RAIDDEVICES = "dispositivo-1 dispositivo-2"
	VAR RAIDNDEVICES = `wc $RAIDDEVICES`

	`mdadm --create --level=$RAIDLEVEL --raid-devices=$RAIDNDEVICES $RAIDDEVICES`
	`mdadm --detail $RAIDNAME --brief >> /etc/mdadm/mdadm.conf`

- LVM

	lvm

	Formato de fichero-de-perfil-de-servicio: [2+]

	nombre-del-grupo-de-volúmenes
	lista-de-dispositivos-en-el-grupo
	nombre-del-primer-volumen tamaño-del-primer-volumen
	nombre-del-segundo-volumen tamaño-del-segundo-volumen ...
	[ max ]

	serverdata
	/dev/sdb1 /dev/sdc1 /dev/sdd1
	software 100GB
	users 500GB

- Servidor NIS
	
	nis_server

	Formato de fichero-de-perfil-de-servicio: [1]

	nombre-del-dominio-nis

	VAR DOMAINNAME = nombre-del-dominio-nis

	`apt-get -y install nis`
	`echo $DOMAINNAME >> /etc/defaultdomain`
	`/usr/lib/yp/ypinit -m`
	`/etc/init.d/nis start`

- Cliente NIS
	
	nis_client

	Formato de fichero-de-perfil-de-servicio: [2]

	nombre-del-dominio-nis
	servidor-nis-al-que-se-desea-conectar

	VAR DOMAINNAME = nombre-del-dominio-nis
	VAR NISSERVER = servidor-nis-al-que-se-desea-conectar

	`apt-get -y install nis`
	`echo "`sed s/"NISCLIENT=false"/"NISCLIENT=true"/g /etc/default/nis`" > /etc/default/nis`
	`echo "ypserver $NISSERVER" >> /etc/yp.conf`
	`/etc/init.d/nis start`


- Servidor NFS

	nfs_server

	Formato de fichero-de-perfil-de-servicio: [1+]

	ruta-del-primer-directorio-exportado
	ruta-del-segundo-directorio-exportado ...

- Cliente NFS
	
	nfs_client
	fichero /etc/fstab

	Formato de fichero-de-perfil-de-servicio: [1]

	ruta-de-directorio-remoto punto-de montaje

- Servidor backup

	backup_server

	Formato de fichero-de-perfil-de-servicio: [1]

	directorio-donde-se-realiza-el-backup

- Cliente backup

	backup_client

	Formato de fichero-de-perfil-de-servicio: [4]

	ruta-del-directorio-del-que-se-desea-hacer-backup
	direccion-del-servidor-de-backup
	ruta-de-directorio-destino-del-backup
	periodicidad-del-backup-en-horas