#!/bin/bash


echo "Iniciando escaneo de puertos con Nmap"


# Validar parámetros
if [ -z "$1" ]; then
  echo "Uso: $0 <IP o localhost> [completo]"
  echo "Parámetro opcional 'completo' para escanear todos los puertos"
  exit 1
fi


OBJETIVO="$1"
TIPO_ESCANEO="$2"


# Verificar si Nmap está instalado
if ! command -v nmap &> /dev/null; then
  echo "Nmap no está instalado. Instalando..."
  sudo apt update && sudo apt install -y nmap || {
	echo "No se pudo instalar Nmap. Abortando."
	exit 1
  }
fi


# Definir tipo de escaneo
if [ "$TIPO_ESCANEO" == "completo" ]; then
  echo "Ejecutando escaneo completo (-p-)..."
  NMAP_CMD="nmap -sS -sV -p- --open $OBJETIVO"
else
  echo "Ejecutando escaneo rápido (puertos comunes)..."
  NMAP_CMD="nmap -sS -sV -Pn --open $OBJETIVO"
fi


# Ejecutar escaneo y guardar resultados
echo "Escaneando $OBJETIVO... esto puede tardar..."
RESULTADO=$($NMAP_CMD)


FECHA=$(date +%Y%m%d_%H%M%S)
ARCHIVO="reporte_nmap_${OBJETIVO}_${FECHA}.txt"
echo "$RESULTADO" > "$ARCHIVO"
echo "Resultado guardado en: $ARCHIVO"

# Verificar si se encontraron puertos abiertos
if ! echo "$RESULTADO" | grep -qE '^[0-9]'; then
  echo "No se detectaron puertos abiertos en $OBJETIVO."
  exit 0
fi


# Listas de clasificación
SEGUROS=(22 80 443)
SOSPECHOSOS=(3000 3306 8080)
PELIGROSOS=(23 21 6667)


# Mostrar clasificación
echo "Clasificación de puertos detectados:"
HAY_RIESGO=false


echo "$RESULTADO" | grep ^[0-9] | while read linea; do
	puerto=$(echo "$linea" | cut -d "/" -f1)
	servicio=$(echo "$linea" | awk '{print $3}')


	echo "→ Puerto abierto: $puerto - Servicio: $servicio"


	if [[ " ${SEGUROS[@]} " =~ " $puerto " ]]; then
    	echo "   Clasificación: SEGURO"
	elif [[ " ${SOSPECHOSOS[@]} " =~ " $puerto " ]]; then
    	echo "   Clasificación: SOSPECHOSO"
    	HAY_RIESGO=true
	elif [[ " ${PELIGROSOS[@]} " =~ " $puerto " ]]; then
    	echo "   Clasificación: PELIGROSO"
    	HAY_RIESGO=true
	else
    	echo "   Clasificación: DESCONOCIDO"
	fi
done


# Mostrar recomendaciones si corresponde
if $HAY_RIESGO; then
	echo
	echo "⚠️  Se detectaron puertos sospechosos o peligrosos."
	echo "Recomendaciones:"
	echo "- Verificá si los servicios en esos puertos son necesarios."
	echo "- Si no se usan, cerralos con un firewall o regla de red."
	echo "- Aplicá reglas de acceso para restringir conexiones externas."
	echo "- Mantené actualizado el software que usa esos puertos."
	echo "- Considerá usar herramientas como fail2ban o firewalld."
	echo
	echo "👉 Si desea cerrar un puerto, ejecute: ./cerrar_puerto.sh <número_de_puerto>"
fi
