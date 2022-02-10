. funciones.sh

function montarDisco() {
    local nombreParticion=`echo $1 | cut -d"/" -f3`
    local fileSystem=`lsblk -f | grep "$nombreParticion" | cut -d" " -f2`
    local rutaParticion=$1
    local montaje=$2
    local fecha=`date +%d/%m/%Y`
    
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

            echo "Montar:${nombreParticion}:${montaje}:${fecha}" >> gestorDisco.log
            menuGestionarDisco
        else
            echo "No se ha podido montar"
            echo "Error montar:${nombreParticion}:${montaje}:${fecha}" >> gestorDisco.log
            menuGestionarDisco
    fi 
}

function desmontarDisco() {
    local rutaParticion=$1
    local fecha=`date +%d/%m/%Y`

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

            local fecha=`date +%d/%m/%Y`
            echo "Desmontar:${rutaParticion}:${fecha}" >> gestorDisco.log

            menuGestionarDisco
        else
            echo "Error montar:${rutaParticion}:${fecha}" >> gestorDisco.log
            menuGestionarDisco
    fi 
}

function automontar() {
    local rutaParticion=$1
    local nombreParticion=`echo $1 | cut -d"/" -f3`
    local fileSystem=`lsblk -f | grep "$nombreParticion" | cut -d" " -f2`
    local rutaMontaje=$2

    echo $rutaParticion $rutaMontaje $fileSystem defaults 0 3 >> /etc/fstab
    
    # -- Crear entrada en los logs y comprobar existencia en fstab (si existe no se escribe sobre el fstab)-- 
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
                    --text="GESTIONAR DISCO" \
                    --tree \
                    --column="Selecciona una opción:" \
                        "Montar Disco" "Desmontar" "Automontaje")

    ans=$?
    if [ $ans -eq 0 ]
    then
        opcion=${opcion::-1} #Quita el | del final
        case $opcion in
                "Montar Disco")
                        discoSelecionado=`ventanaSelecionarDisco` #Función que devolverá "discoSelecionado"
                        if [ ${discoSelecionado} != "return" ] #Se ha selecionado un disco
                            then
                                formulario=`ventanaMontarDiscoFormulario $discoSelecionado`
                                
                                if [ $? -eq 0 ] #El usuario no ha cerrado el formulario
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
                        discoSelecionado=`ventanaSelecionarDisco` #Función que devolverá "discoSelecionado"

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
                                        --buttons-layout=spread \
                                        --field="Partición: ":CB \
                                        --field="Punto montaje" \
                                        "${strParticiones}" '/mnt')
                        ans=$?
                        if [ $ans -eq 0 ]
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
                *)
                    echo "Unexpected"
                    ;;
        esac
    else
        ./menu.sh
    fi
}

menuGestionarDisco #Invocar interfaz