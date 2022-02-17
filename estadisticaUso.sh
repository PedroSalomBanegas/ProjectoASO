# --field=":LBL" \ --> Línea en blanco

function mostrarLogs() {
    datos=($@)
    local archivo=${datos[0]}
    local evento=${datos[1]}
    local particion=${datos[2]}
    local fecha=${datos[3]}
    local tipoEvento=${datos[4]}
    local filtroFecha=${datos[5]}
    local fechaUsuario=${datos[6]}
    echo "$archivo - $evento - $particion - $fecha - $tipoEvento - $filtroFecha - $fechaUsuario"

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

    case $tipoEvento in
        "Todos")
            local datosFiltrados=`grep -a "" ${archivo}`
            ;;
        "Correctos")
            local datosFiltrados=`grep -a -v "Error" ${archivo}`
            ;;
        "Errores")
            local datosFiltrados=`grep -a "Error" ${archivo}`
            ;;
        *)
            echo "Unexpected"
            ;;
    esac

    echo $datosFiltrados

    # -- Leer datos y formatear para YAD --
    IFS=":"
    for datos in $datosFiltrados
        do
            resultado="$resultado $datos"
        done
        resultado=`echo $resultado | tr '\n' ' '`
    
    IFS=" "
    opcion=$(yad --list \
                 --title="MENU" \
                 --height=220 \
                 --width=150 \
                 --button=Volver:0 \
                 --button="Menú Principal:1" \
                 --center \
                 --buttons-layout=spread \
                 --text-align=center \
                 --text="RESULTADO" \
                 --tree \
                 ${listaCampos} \
                 ${resultado})

    echo "botón = $?"

    if [ $? -eq 0 ]
        then
            generarFormularioLogs
        else
            ./menu.sh
    fi
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
                --field="Fecha":DT \
                "gestorDisco.log!formParticion.log" "" "" "" "" "" "" "" "Todos!Correctos!Errores" "Desactivado!Igual!Anterior!Posterior")
    ans=$?
    if [ $ans -eq 0 ]
    then
        IFS="|" read -r -a array <<< "$datos" #Recoger los datos y guardarlos en un array
        mostrarLogs ${array[@]}
    else
        ./menu.sh
    fi
}

generarFormularioLogs #Invocar formulario

