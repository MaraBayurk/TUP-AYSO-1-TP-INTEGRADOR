#!/bin/bash

# Verifica que haya recibido un número de puerto
if [ -z "$1" ]; then
	echo "Debe ingresar un número de puerto. Uso: ./cerrar_puerto.sh 3000"
	exit 1
fi

PUERTO=$1

# Cierra el puerto usando iptables (requiere sudo)
echo "Cerrando puerto $PUERTO..."
sudo iptables -A INPUT -p tcp --dport $PUERTO -j DROP
echo "Puerto $PUERTO bloqueado con éxito."
