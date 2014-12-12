#! /bin/bash

#Contador = 0 (Máquina destino)
#Contador = 1 (Nombre servicio)
#Contador = 2 (Fichero perfil configuración)
C=0

#Se analiza cada palabra del fichero de configuración ($1)
for line in $(cat $1); do
	if [ $C = 0 ];
	then
		#Máquina destino
		MAQUINA=$line
		
	elif [ $C = 1 ];
	then
		#Nombre servicio
		SERVICIO=$line
		
	elif [ $C = 2 ];
	then
		#Fichero perfil configuración
		FCONF=$line
		
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