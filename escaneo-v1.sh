
#!/bin/bash

echo "-------------------------------------------------"
echo "Iniciando proceso de escaneo con Nmap"
echo "-------------------------------------------------"

# Verificar si se pasó una dirección IP o nombre de host como argumento
if [ -z "$1" ]; then
  echo "Uso: $0 <dirección IP o nombre de host>"
  exit 1
fi

# Guardar el parámetro
objetivo="$1"

# Verificar si Nmap está instalado
if ! command -v nmap &> /dev/null; then
  echo "Nmap no está instalado. Intentando instalarlo..."
  sudo apt update && sudo apt install -y nmap || {
    echo "No se pudo instalar Nmap. Abortando."
    exit 1
  }
fi

# Ejecutar el escaneo y guardar el resultado en un archivo
fecha=$(date +%Y%m%d_%H%M%S)
archivo_salida="reporte_nmap_$objetivo_$fecha.txt"

# echo "Realizando escaneo sobre $objetivo..."
nmap -sS -sV "$objetivo" -oN "$archivo_salida"
# nmap -Pn -sS -sV "$objetivo"


echo "Escaneo finalizado. Resultados guardados en: $archivo_salida"
