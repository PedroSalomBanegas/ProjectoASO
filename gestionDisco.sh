. funciones.sh

function iniciarGestionDisco() {
    discoSelecionado=`ventanaSelecionarDisco`

    menuGestionarDisco #Invocar interfaz
}

function montarDisco() {
    local nombreParticion=`echo $1 | cut -d"/" -f3`
    local fileSystem=`lsblk -f | grep "$nombreParticion" | cut -d" " -f2`
    local rutaParticion=$1
    local montaje=$2
    local fecha=`date +%Y/%m/%d`
    
    sudo mount -t $fileSystem $rutaParticion $montaje

    if [ $? -eq 0 ]
        then
            echo "Montaje correcto"
            texto="¡La partición se ha montado correctamente!"
            yad --title="Montaje Correcto" \
            --image=gtk-info \
            --width=250 \
            --height=80 \
            --button=Continuar:0 \
            --center \
            --text-align=center \
            --text="${texto}"

            echo "Montar:${nombreParticion}:${fecha}" >> gestorDisco.log #entrada log
            menuGestionarDisco
        else
            echo "No se ha podido montar"
            echo "Error_montar:${nombreParticion}:${fecha}" >> gestorDisco.log #entrada log
            menuGestionarDisco
    fi 
}

function desmontarDisco() {
    local rutaParticion=$1
    local fecha=`date +%Y/%m/%d`
    local nombreParticion=`echo $1 | cut -d"/" -f3`

    sudo umount ${rutaParticion}

    if [ $? -eq 0 ]
        then
            texto="¡Se ha desmontado la partición correctamente!"
            yad --title="Desmontaje Correcto" \
            --image=gtk-info \
            --width=250 \
            --height=80 \
            --button=Continuar:0 \
            --center \
            --text-align=center \
            --text="${texto}"

            local fecha=`date +%Y/%m/%d`
            echo "Desmontar:${nombreParticion}:${fecha}" >> gestorDisco.log #entrada log

            menuGestionarDisco
        else
            echo "Error_Desmontar:${nombreParticion}:${fecha}" >> gestorDisco.log #entrada log
            menuGestionarDisco
    fi 
}

function automontar() {
    local rutaParticion=$1
    local nombreParticion=`echo $1 | cut -d"/" -f3`
    local fileSystem=`lsblk -f | grep "$nombreParticion" | cut -d" " -f2`
    local rutaMontaje=$2
    local fecha=`date +%Y/%m/%d`

    local existencia=`particionExisteFstab ${rutaParticion}`

    if [ $existencia = "false" ] #Si no existe una entrada en fstab
        then
            echo $rutaParticion $rutaMontaje $fileSystem defaults 0 3 >> /etc/fstab # Escribir nueva entrada a fstab
            sudo mount -a
            
            texto="¡Se ha montado ${nombreParticion} correctamente!"
            yad --title="Automontaje Correcto"  \
                --image=gtk-info \
                --width=250 \
                --height=80 \
                --button=Continuar:0 \
                --center \
                --text-align=center \
                --text="${texto}"

            echo "Automontar:${nombreParticion}:${fecha}" >> gestorDisco.log #entrada log
            menuGestionarDisco
        else
            echo "Error_Automontar:${nombreParticion}:${fecha}" >> gestorDisco.log #entrada log
            ./menu.sh
    fi
}

function quitarAutomontar() {
    local existencia=`particionExisteFstab $1`
    local nombreParticion=`echo $1 | cut -d"/" -f3`
    local fecha=`date +%Y/%m/%d`

    if [ $existencia = "true" ]
        then
            sed "/$nombreParticion/d" "/etc/fstab" > $$.tmp #No funciona redirecionando directamente a fstab
            local resultado=$?

            if [ $resultado -eq 0 ] #control error, si sed no funciona no se reescribe fstab ( -- correción intermedia -- )
                then
                    cat $$.tmp > /etc/fstab 
                    rm $$.tmp #Eliminar archivo temporal

                    texto="Automontaje borrado sobre $nombreParticion correctamente"
                    yad --title="Automontaje borrado!"  \
                        --image=gtk-info \
                        --width=250 \
                        --height=80 \
                        --button=Continuar:0 \
                        --center \
                        --text-align=center \
                        --text="${texto}"

                    echo "Automontar_eliminado:${nombreParticion}:${fecha}" >> gestorDisco.log #entrada log
                    menuGestionarDisco
                else
                    echo "error, no se ha podido borrar"
                    echo "Error_eliminar_Automontar:${nombreParticion}:${fecha}" >> gestorDisco.log #entrada log
                    ./menu.sh
            fi
        else
            echo $1
            echo false
            texto="No existe una entrada con $nombreParticion"
            yad --title="Error eliminar entrada" \
                --image=gtk-info \
                --width=250 \
                --height=80 \
                --button=Continuar:0 \
                --center \
                --text-align=center \
                --text="${texto}"

            echo "error, no se ha podido borrar"
        echo "Error_eliminar_Automontar:${nombreParticion}:${fecha}" >> gestorDisco.log #entrada log
                    ./menu.sh
    fi
}

function ventanaSelecionarParticion() {
    local particiones=`obtenerParticiones $1`
    local strParticiones=`formatearStringListaYAD $particiones`

    seleccion=$(yad --list \
                 --title="MENU" \
                 --height=220 \
                 --width=150 \
                 --button=Salir:1 \
                 --button=Seleccionar:0 \
                 --center \
                 --buttons-layout=spread \
                 --text-align=center \
                 --text="Partición a desmontar" \
                 --tree \
                 --column="Selecciona una opción:" \
                    ${strParticiones})

    ans=$? #respuesta del usuario
    if [ $ans -eq 0 ]
    then
    
        IFS="|" read -r -a array <<< "$seleccion" #Recoger los datos y guardarlos en un array

        echo ${array[0]}
    else
        echo "return"
    fi
}

function menuGestionarDisco(){
    opcion=$(yad --list \
                    --title="MENU" \
                    --height=220 \
                    --width=150 \
                    --button=Volver:1 \
                    --button=Seleccionar:0 \
                    --buttons-layout=spread \
                    --center \
                    --text-align=center \
                    --text="GESTIONAR DISCO \n <span weight=\"bold\">Disco: ${discoSelecionado}</span>" \
                    --tree \
                    --column="Selecciona una opción:" \
                        "Montar Partición" "Desmontar" "Automontaje" "Eliminar Automontaje" "Cambiar Disco")

    ans=$?
    if [ $ans -eq 0 ]
    then
        opcion=${opcion::-1} #Quita el | del final
        case $opcion in
                "Montar Partición")
                        #discoSelecionado=`ventanaSelecionarDisco` #Función que devolverá "discoSelecionado"
                        if [ ${discoSelecionado} != "return" ] #Se ha selecionado un disco
                            then
                                formulario=`ventanaMontarDiscoFormulario $discoSelecionado`
                                
                                if [ ${formulario} != "" ] #El usuario no ha cerrado el formulario
                                    then
                                        IFS="|" read -r -a datos <<< "$formulario" #recoger los datos
                                        montarDisco ${datos[0]} ${datos[1]}
                                    else
                                        menuGestionarDisco
                                fi
                            else
                                ./menu.sh
                        fi
                    ;;
                "Desmontar")
                        #discoSelecionado=`ventanaSelecionarDisco` #Función que devolverá "discoSelecionado"

                        if [ ${discoSelecionado} != "return" ]
                            then
                                particionSelecionada=`ventanaSelecionarParticion $discoSelecionado`

                                if [ $particionSelecionada != "return" ] #Se ha selecionado una partición
                                    then
                                        desmontarDisco $particionSelecionada
                                    else
                                        menuGestionarDisco
                                fi
                            else
                                ./menu.sh
                        fi
                    ;;
                "Automontaje")
                        local particionesDisponibles=`obtenerParticiones /dev/sd\?`
                        local strParticiones=`formatearStringYAD $particionesDisponibles`

                        local seleccion=$(yad --form \
                                        --title="Formulario automontaje" \
                                        --text="¿Qué partición quieres que se monte automáticamente?" \
                                        --center \
                                        --button=Salir:1 \
                                        --button=Seleccionar:0 \
                                        --buttons-layout=spread \
                                        --field="Partición: ":CB \
                                        --field="Punto montaje" \
                                        "${strParticiones}" '/mnt')

                        if [ $? -eq 0 ]
                            then
                                IFS="|" read -r -a array <<< "$seleccion"
                                if [ $seleccion != "" ] #Se ha selecionado una partición
                                    then
                                        automontar ${array[0]} ${array[1]}
                                    else
                                        menuGestionarDisco
                                fi
                            else
                                ./menu.sh
                        fi
                    ;;
                "Eliminar Automontaje")
                        local particiones=`obtenerParticiones /dev/sd\?`
                        local strParticiones=`formatearStringListaYAD $particiones`

                        seleccion=$(yad --list \
                                    --title="MENU" \
                                    --height=220 \
                                    --width=150 \
                                    --button=Salir:1 \
                                    --button=Seleccionar:0 \
                                    --center \
                                    --buttons-layout=spread \
                                    --text-align=center \
                                    --text="Partición a desmontar" \
                                    --tree \
                                    --column="Selecciona una opción:" \
                                        ${strParticiones})

                        ans=$? #respuesta del usuario
                        seleccion=${seleccion::-1} #Quita el | del final
                        quitarAutomontar $seleccion
                    ;;
                "Cambiar Disco")
                    discoSelecionado=`ventanaSelecionarDisco`
                    menuGestionarDisco
                    ;;
                *)
                    echo "Unexpected"
                    ;;
        esac
    else
        ./menu.sh
    fi
}