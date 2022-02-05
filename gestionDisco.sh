. funciones.sh

function montarDisco() {
    local nombreParticion=`echo $1 | cut -d"/" -f3`
    local fileSystem=`lsblk -f | grep "$nombreParticion" | cut -d" " -f2`
    local rutaParticion=$1
    local montaje=$2

    sudo mount -t $fileSystem $rutaParticion $montaje

    if [ $? -eq 0 ]
        then
            echo "Montaje correcto"
            menuGestionarDisco
        else
            echo "No se ha podido montar"
            menuGestionarDisco
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
                        ventanaSelecionarDisco #Función que devolverá "discoSelecionado"

                        if [ ${discoSelecionado} != "return" ]
                            then
                                formulario=`ventanaMontarDiscoFormulario`
                                
                                IFS="|" read -r -a datos <<< "$formulario" #recoger los datos
                                #echo "Partición: ${datos[0]}"
                                #echo "Punto de montaje: ${datos[1]}"
                                montarDisco ${datos[0]} ${datos[1]}
                            else
                                ./menu.sh
                        fi
                    ;;
                "Desmontar")
                    echo "Desmontar"
                    ;;
                "Automontaje")
                    echo "Automontaje"
                    ;;
                *)
                    echo "Unexpected"
                    ;;
        esac
    else
        ./menu.sh
    fi
}

menuGestionarDisco
#ventanaSelecionarDisco #Invocar interfaz