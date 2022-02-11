. funciones.sh

seleccion=$(yad --list \
                 --title="MENU" \
                 --height=220 \
                 --width=200 \
                 --button=Salir:1 \
                 --center \
                 --buttons-layout=spread \
                 --text-align=center \
                 --text="INFO" \
                 --tree \
                 --column="Particiones" \
                 --column="File System" \
                 --column="Espacio total" \
                 --column="Gráfico espacio utilizado" \
                    sda1 ext2 0% XXXX00000 sda5 ext4 60% XXXX00000 sdb1 ext2 30% XXXX00000)
                
               

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
                IFS="|" read -r -a array <<< "$part"
                disco=${array[0]}
                cont=0
                string=""
              
            
                valor=""
                numParticiones=`contParam ls $disco?`

                while [ $cont -lt $numParticiones ]
                    do
                        let cont=cont+1
                        if [ ${array[1]} = "TRUE" ]
                            then
                                valor=`ls $disco? | cut -d" " -f${cont}`
                                echo $valor
                        fi

                        if [ ${array[2]} = "TRUE" ]
                            then
                                part=${valor: -4} #recoge las ultimas 4 letras
                                echo $part
                                fileSystem=`sudo lsblk -f | grep "$part" | cut -d" " -f2`
                                echo $fileSystem
                                if [ -z fileSystem ]
                                    then
                                        fileStr="sinFormato"
                                    else
                                        fileStr=$fileSystem
                                fi

                        fi
                        string="$string $valor $fileStr"
                    done
                    echo $string

#particiones con cut y ls
#file system --> fileSystem=`lsblk -f | grep "$nombreParticion" | cut -d" " -f2`
#Espacio total --> lsblk /dev/sdb
#Espacio libre --> df /dev/sda?