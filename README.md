# updateJackett
Script para actualizar Jackett en Raspberry Pi OS

Este script comprueba la última versión de Jackett desde GitHub y descarga la actualización si existe  
Este script está pensado para una instalación de Jackett en Raspberry Pi OS  
El script espera que Jackett esté instalado en /opt/Jackett  
El script espera que Jackett se ejecute bajo el usuario pi 

### ¿Cómo se utiliza?

**1. Descargar el script en el directorio HOME**<br>
<code>cd /home/pi</code><br>
<code>wget https://raw.githubusercontent.com/egrueda/updateJackett/master/updateJackett.sh</code>

**2. Asignarle permisos de ejecución**<br>
<code>chmod +x updateJackett.sh</code>

**3. Ejecutar el script de actualización**<br>
<code>./updateJackett.sh</code>

### Configuración

Puedes editar el archivo updateJackett.sh para ajustarlo a tus necesidades o adaptarlo a tu sistema.<br>
 - Modifica la variable **JACKETT_PATH** para ajustar el directorio donde tienes instalado Jackett<br>
 - Modifica la variable **JACKETT_USER** para ajustar el nombre de usuario bajo el que se ejecuta Jackett<br>

