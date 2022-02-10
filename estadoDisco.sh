. funciones.sh

part=$(yad --form \
                --height=220 \
                --width=150 \
                --button=Salir:1 \
                --button=Seleccionar:0 \
                --title="MENU" \
                --center \
                --field="Discos":CB \
                '/dev/sda!/dev/sdb' \
                --field="Particiones":CHK \
                --field="File System":CHK \
                --field="Espacio total":CHK \
                --field="Espacio libre":CHK \
                --field="Gráfico espacio utilizado":CHK )
                
                ans=$?
                echo ${part}
#particiones con cut y ls
#file system --> fileSystem=`lsblk -f | grep "$nombreParticion" | cut -d" " -f2`
#Espacio total --> lsblk /dev/sdb
#Espacio libre --> df /dev/sda?
