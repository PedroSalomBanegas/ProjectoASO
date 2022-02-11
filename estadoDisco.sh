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
                cont=1
                check=`echo $part | cut -d"|" -f${cont}`
                disco=$check
                col=0
                while [ "$check" != "" ]
                    do
                        let cont=cont+1
                        check=`echo $part | cut -d"|" -f${cont}`
                        if [ "TRUE" = "$check" ]
                            then
                                case $cont in
                                            "2")
                                            let col=col+1
                                                echo "Particiones"
                                            ;;
                                            "3")
                                            let col=col+1
                                                echo "File System"
                                            ;;
                                            "4")
                                            let col=col+1
                                                echo "Espacio total"
                                            ;;
                                            "5")
                                            let col=col+1
                                                echo "Espacio libre"
                                            ;;
                                            "6")
                                            let col=col+1
                                            echo "Numero columnas "$col
                                                echo "Gráfico"
                                            ;;
                                            *)
                                                echo "Unexpected"
                                            ;;
                                esac
                        fi
                    done

#particiones con cut y ls
#file system --> fileSystem=`lsblk -f | grep "$nombreParticion" | cut -d" " -f2`
#Espacio total --> lsblk /dev/sdb
#Espacio libre --> df /dev/sda?