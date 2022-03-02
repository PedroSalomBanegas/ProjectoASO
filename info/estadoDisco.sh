. funciones/funciones.sh

function iniciarEstadoDisco() {
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
                    --field="Espacio en Uso":CHK )
                    
                    ans=$?
    if [ $ans -eq 0 ]
        then
                    
                    IFS="|" read -r -a array <<< "$part"
                    disco=${array[0]}
                    cont=0
                    string=""
                    column=""
                    valor=""
                    numParticiones=`ls $disco? | wc -l`
                    width=0

                    while [ $cont -lt $numParticiones ]
                        do
                            let cont=cont+1
                            lista=`ls $disco?`
                            valor=`echo $lista | cut -d" " -f${cont}`
                            part=${valor: -4} #recoge las ultimas 4 letras
                            fileSystem=`sudo lsblk -f | grep "$part" | cut -d" " -f2`

                            if [ ${array[1]} = "TRUE" ]
                                then
                                    partic=$valor
                            fi

                            if [ ${array[2]} = "TRUE" ]
                                then
                                    
                                    if [ -z $fileSystem ]
                                        then
                                            fileStr="sinFormato"
                                        else
                                            fileStr=$fileSystem
                                    fi
                            fi

                            if [ ${array[3]} = "TRUE" ]
                                then
                                    espacioTotal=`sudo lsblk $disco | grep "$part" | awk '{print $4}'`
                                    #awk no esta documentado en la 2º entrega
                                    #puede hacer print de una linea especificando parámetros
                                    #solución al cut
                            fi

                            if [ ${array[4]} = "TRUE" ]
                                then
                                    espacioUso=`sudo df $valor | grep "$part" | awk '{print $5}'`
                                    if [ -z $espacioUso ]
                                        then
                                            if [ -z $fileSystem ] #un poco chapuza pero sdb da errores raros
                                                then
                                                    uso="X"
                                                else
                                                    uso="0%"
                                            fi
                                        else
                                            uso=$espacioUso
                                    fi
                                    
                            fi
                            string="$string $partic $fileStr $espacioTotal $uso"
                        done

                    if [ ${array[1]} = "TRUE" ]
                        then
                            let width=width+125
                            column="$column --column="Particiones""
                    fi
                    
                    if [ ${array[2]} = "TRUE" ]
                        then
                            let width=width+125
                            column="$column --column="FileSystem""
                    fi

                    if [ ${array[3]} = "TRUE" ]
                        then
                            let width=width+125
                            column="$column --column="EspacioTotal""
                    fi

                    if [ ${array[4]} = "TRUE" ]
                        then
                            let width=width+125
                            column="$column --column="EspacioEnUso""
                    fi
                    


                    seleccion=$(yad --list \
                                        --title="MENU" \
                                        --height=225 \
                                        --width=$width \
                                        --button=Salir:1 \
                                        --center \
                                        --buttons-layout=spread \
                                        --text-align=center \
                                        --text="INFO" \
                                        --tree \
                                            $column \
                                            $string )
        else
            ./menu.sh
        fi
}