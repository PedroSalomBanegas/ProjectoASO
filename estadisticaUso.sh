
# --field=":LBL" \ --> Línea en blanco

function mostrarLogs() {

    unset evento
    unset particion
    unset fecha
    unset listaCampos
    unset resultado

    datos=($@)
    local archivo=${datos[0]}
    local evento=${datos[1]}
    local particion=${datos[2]}
    local fecha=${datos[3]}
    local tipoEvento=${datos[4]}
    local filtroFecha=${datos[5]}
    local fechaInicial=${datos[6]}
    local fechaFinal=${datos[7]}

    # -- GENERAR LOS CAMPOS --
    if [ $evento = 'TRUE' ]
        then
            local listaCampos="${listaCampos} --column=Evento"
    fi

    if [ $particion = 'TRUE' ]
        then
            local listaCampos="${listaCampos} --column=Particion"
    fi

    if [ $fecha = 'TRUE' ]
        then
            local listaCampos="${listaCampos} --column=Fecha"
    fi

    # -- RECOGER DATOS CON LOS FILTROS --

    filtrarFecha $fechaInicial $fechaFinal $filtroFecha

    #filteredString=`filtrarFecha $fechaInicial $fechaFinal $filtroFecha`
    #echo $filteredString


    case $tipoEvento in
        "Todos")
            local datosFiltrados=`grep -a "" filteredList.tmp`
            ;;
        "Correctos")
            local datosFiltrados=`grep -a -v "Error" filteredList.tmp`
            ;;
        "Errores")
            local datosFiltrados=`grep -a "Error" filteredList.tmp`
            ;;
        *)
            echo "Unexpected"
            ;;
    esac

    rm filteredList.tmp

    # -- Leer datos y formatear para YAD --
    IFS=$'\n'
    for datos in $datosFiltrados
        do
            if [ $evento = 'TRUE' ]
                then
                    local eventoFiltro=`echo ${datos} | cut -d":" -f1`
                    local resultado="${resultado} ${eventoFiltro}"
            fi

            if [ $particion = 'TRUE' ]
                then
                    local particionFiltro=`echo ${datos} | cut -d":" -f2`
                    local resultado="${resultado} ${particionFiltro}"
            fi

            if [ $fecha = 'TRUE' ]
                then
                    local fechaFiltro=`echo ${datos} | cut -d":" -f3`
                    local resultado="${resultado} ${fechaFiltro}"
            fi
        done
        
    IFS=" "
    opcion=$(yad --list \
                 --title="MENU" \
                 --height=220 \
                 --button=Volver:0 \
                 --button="Menú Principal:1" \
                 --center \
                 --buttons-layout=spread \
                 --text-align=center \
                 --text="RESULTADO" \
                 --tree \
                 ${listaCampos} \
                 ${resultado})

    if [ $? -eq 0 ]
        then
            generarFormularioLogs
        else
            ./menu.sh
    fi
}

function filtrarFecha() {

    if [ $# -eq 2 ]
        then
            local inicial=$1
            local tipoFiltro=$2

            local dayInical=`echo $inicial | cut -d"/" -f1`
            local monthInical=`echo $inicial | cut -d"/" -f2`
            local yearInicial=`echo $inicial | cut -d"/" -f3`
            local yearInicial=20${yearInicial} #Formatear el año para filtrar correctamente
    elif [ $# -eq 3 ]
        then
            local inicial=$1
            local final=$2
            local tipoFiltro=$3

            local dayInical=`echo $inicial | cut -d"/" -f1`
            local monthInical=`echo $inicial | cut -d"/" -f2`
            local yearInicial=`echo $inicial | cut -d"/" -f3`
            local yearInicial=20${yearInicial} #Formatear el año para filtrar correctamente

            local dayFinal=`echo $final | cut -d"/" -f1`
            local monthFinal=`echo $final |cut -d"/" -f2`
            local yearFinal=`echo $final | cut -d"/" -f3`
            local yearFinal=20${yearFinal} #Formatear el año para filtrar correctamente
    else
        local tipoFiltro=$1
    fi

    local dataLog=`cat gestorDisco.log`

    # ================================== PENDIENTE ==================================
    # -------------------------------------------------------------------------------
    # --------- Filtro para decisión fecha (Todas, igual, entre --> (hecho) ---------
    # -------------------------------------------------------------------------------

    case $tipoFiltro in
        "Entre")
            IFS=$'\n'
            for str in $dataLog
                do
                    local dataFilter=`echo "$str" | cut -d":" -f3 | sed 's/\///g'`
                    if [ $dataFilter -ge $yearInicial$monthInical$dayInical ]
                        then
                            if [ -z $previousFilteredString ]
                                then
                                    local previousFilteredString="${str}"
                                else
                                    local previousFilteredString="${previousFilteredString} ${str}"
                            fi
                            
                    fi
                done

            IFS=' '
            for str in $previousFilteredString
                do
                    local dataFilter=`echo "$str" | cut -d":" -f3 | sed 's/\///g'`
                    if [ $dataFilter -le $yearFinal$monthFinal$dayFinal ]
                        then
                            echo $str >> filteredList.tmp
                    fi
                done
            ;;
        "Desactivado")
                cat gestorDisco.log > filteredList.tmp
            ;;
        "Igual")
            IFS=$'\n'
            for str in $dataLog
                do
                    local dataFilter=`echo "$str" | cut -d":" -f3 | sed 's/\///g'`
                    if [ $dataFilter -eq $yearInicial$monthInical$dayInical ]
                        then
                            echo $str >> filteredList.tmp
                    fi
                done
            ;;
    esac
}

function generarFormularioLogs() {

    datos=$(yad --form \
                --title="Visor de registros" \
                --text="¿Qué quieres mostrar de los registros?" \
                --center \
                --field="Archivo:CB" \
                --field=":LBL" \
                --field="Elige los campos a mostrar:LBL" \
                --field="Evento:CHK" \
                --field="Partición:CHK" \
                --field="Fecha:CHK" \
                --field=":LBL" \
                --field="Filtros:LBL" \
                --field="Tipo de evento:CB"  \
                --field="Filtrar por fecha:CB"  \
                --field="Fecha Inicio":DT \
                --field="Fecha Final":DT \
                "gestorDisco.log" "" "" "" "" "" "" "" "Todos!Correctos!Errores" "Desactivado!Entre!Igual")
    ans=$?
    if [ $ans -eq 0 ]
    then
        IFS="|" read -r -a array <<< "$datos" #Recoger los datos y guardarlos en un array
        mostrarLogs ${array[@]}
    else
        ./menu.sh
    fi
}
