#!/bin/bash
# updateJacket.sh 1.0
# Este script descarga e instala la última versión de Jackett

echo "Actualizado de Jackett para Raspberry Pi OS"
echo

# Ajustar al entorno
JACKETT_PATH=/opt/Jackett
JACKETT_USER=pi
JACKETT_TARBALL=Jackett.Binaries.LinuxARM32.tar.gz

# Comprobaciones previas
CHECK_WGET=`which wget`
if [ $? -ne 0 ]; then echo "Error: No se ha encontrado el comando wget"; exit 1; fi

CHECK_TAR=`which tar`
if [ $? -ne 0 ]; then echo "Error: No se ha encontrado el comando tar"; exit 1; fi

if [ ! -w "$JACKETT_PATH" ]; then echo "Error: No se puede escribir en $JACKETT_PATH"; exit 1; fi

CHECK_USER=`id $JACKETT_USER 2>%1 > /dev/null`
if [ $? -ne 0 ]; then echo "Error: No existe el usuario $JACKETT_USER"; exit 1; fi

if [ ! -f $JACKETT_PATH/jackett.deps.json ]; then echo "No se encuentra jackett.deps.json. ¿Está Jackett instalado?"; exit 1; fi

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' |                                  # Pluck JSON value
    sed 's/[^0-9.]//g'                                              # Version number only
}

# Comparar por MAJOR.MINOR.PATCHLEVEL
compare_versions() {
    MAJOR1=`echo $1 | cut -d "." -f 1`
    MAJOR2=`echo $2 | cut -d "." -f 1`
    if [ $MAJOR1 -gt $MAJOR2 ]; then return 1; fi
    if [ $MAJOR2 -gt $MAJOR1 ]; then return 2; fi

    MINOR1=`echo $1 | cut -d "." -f 2`
    MINOR2=`echo $2 | cut -d "." -f 2`
    if [ $MINOR1 -gt $MINOR2 ]; then return 1; fi
    if [ $MINOR2 -gt $MINOR1 ]; then return 2; fi

    PATCHLEVEL1=`echo $1 | cut -d "." -f 3`
    PATCHLEVEL2=`echo $2 | cut -d "." -f 3`
    if [ $PATCHLEVEL1 -gt $PATCHLEVEL2 ]; then return 1; fi
    if [ $PATCHLEVEL2 -gt $PATCHLEVEL1 ]; then return 2; fi

    return 0
}

# Extraer version instalada
echo "Comprobando versión instalada..."
CURRENT_VERSION=`grep Jackett.Common $JACKETT_PATH/jackett.deps.json | head -n 1 | cut -d ":" -f 2 | sed 's/[^0-9.]//g'`
echo "Versión instalada: $CURRENT_VERSION"
echo

# Extraer version mas reciente de Jackett
echo "Comprobando última versión desde GitHub..."
LATEST_VERSION=`get_latest_release Jackett/Jackett`
echo "Última versión: $LATEST_VERSION"
echo

compare_versions $LATEST_VERSION $CURRENT_VERSION
COMPARE_RESULT=$?
echo "Comparando versiones: $COMPARE_RESULT"

if [ $COMPARE_RESULT -eq 0 ]; then echo "Ya tienes instalada la última versión :-)"; exit 0; fi
if [ $COMPARE_RESULT -eq 2 ]; then echo "Tienes instalada una versión más actual (¿?)"; exit 1; fi
if [ $COMPARE_RESULT -eq 1 ]; then echo "¡Hay una actualización disponible!"; fi
echo

# Descargar la última versión
echo "Descargando Jackett $LATEST_VERSION"
wget -q -O /tmp/$JACKETT_TARBALL -c https://github.com/Jackett/Jackett/releases/download/v$LATEST_VERSION/$JACKETT_TARBALL
if [ $? -ne 0 ]; then echo "Error en la descarga"; exit 1; fi

# Detener Jackett
echo "Deteniendo servicio Jackett"
sudo systemctl stop jackett
if [ $? -ne 0 ]; then echo "Error al detener Jackett"; exit 1; fi

# Descomprimir en /opt/Jackett
echo "Descomprimiendo $JACKETT_TARBALL"
tar zxf /tmp/$JACKETT_TARBALL -C /opt --checkpoint=.100
if [ $? -ne 0 ]; then echo "Error al descomprimir el archivo"; exit 1; fi
echo

# Borrar archivo temporal
echo "Borrando /tmp/$JACKETT_TARBALL"
rm /tmp/$JACKETT_TARBALL
if [ $? -ne 0 ]; then echo "Error al borrar el archivo"; exit 1; fi

# Iniciar Jackett
echo "Iniciando servicio Jackett"
sudo systemctl start jackett
if [ $? -ne 0 ]; then echo "Error al iniciar Jackett"; exit 1; fi

echo 
echo "Jackett ha sido actualizado a la versión $LATEST_VERSION"
echo
exit 0
