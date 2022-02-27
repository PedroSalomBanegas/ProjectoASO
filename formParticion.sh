. funciones.sh

disco=`ventanaSelecionarDisco`

if [ "$disco" = "return" ]
    then
        ./menu.sh
        exit
fi

opcion=$(yad --list \
                 --title=$disco \
                 --height=220 \
                 --width=150 \
                 --button=Salir:1 \
                 --button=Seleccionar:0 \
                 --center \
                 --buttons-layout=spread \
                 --text-align=center \
                 --text="Formatear y Particionar" \
                 --tree \
                 --column="Selecciona una opción:" \
                    "Añadir Particion" "Eliminar Particion" "Formatear" )
ans=$?
if [ $ans -eq 0 ]
then
    lista=`discosConectados`
    listaYAD=`formatearStringYAD $lista`
    listaMKFS=`obtenerParticiones $disco`
    yadMKFS=`formatearStringYAD $listaMKFS`
    listaCheck=`checklist $disco`
    restante=`espacioRestante $disco`
    opcion=${opcion::-1} #Quita el | del final
    case $opcion in
            "Añadir Particion")
                part=$(yad --form \
                --height=100 \
                --width=150 \
                --button=Salir:1 \
                --button=Seleccionar:0 \
                --title=$disco \
                --center \
                --field="Espacio Restante: $restante":LBL \
                '' \
                --field="Tamaño MiB":TXT \
                '' \
                --field="Tipo":CB \
                'Primaria!Extendida' )
                ans=$?
                if [ $ans -eq 0 ]
                then
                    echo ${part} > test.txt 
                    seleccion=`sed 's/|/ /g' test.txt`
                    añadirParticion $disco $seleccion
                    rm test.txt
                    #disco=`echo "$seleccion" | cut -d" " -f1` 
                    local fecha=`date +%Y/%m/%d`
                    echo "AñadirParticion:${disco}:${fecha}" >> gestorDisco.log
                else 
                    ./formParticion.sh
                fi
                ;;
            "Eliminar Particion")
                eliminar=$(yad --list \
                --title=$disco \
                --height=200 \
                --width=250 \
                --center \
                --button=Salir:1 \
                --button=Seleccionar:0 \
                --text="Selecciona particiones a eliminar:" \
                --checklist \
                --column="" \
                --column="Particiones del sistema" \
                $listaCheck )
                ans=$?
                if [ $ans -eq 0 ]
                then  
                    eliminarParticion ${eliminar}
                else
                   
                    ./formParticion.sh
                fi
                ;; 
            "Formatear")
                formateo=$(yad --form \
                --height=220 \
                --width=150 \
                --button=Salir:1 \
                --button=Seleccionar:0 \
                --title=$disco \
                --center \
                --field="File System":CB \
                'ext2!ext4'\
                --field="Partición a formatear":CB \
                ${yadMKFS} )
                ans=$?
                if [ $ans -eq 0 ]
                then  
                    echo ${formateo} > test.txt 
                    seleccion=`sed 's/|/ /g' test.txt` #intercambia | por " "
                    echo -e "s\n" | sudo mkfs.$seleccion
                    rm test.txt
                    fileSys=`echo "$seleccion" | cut -d" " -f1` 
                    par=`echo "$seleccion" | cut -d" " -f2` 
                    local fecha=`date +%Y/%m/%d`
                    echo "Formateo:${par}:${fecha}" >> gestorDisco.log
                else
                    ./formParticion.sh
                fi
                ;;   
            *)
                echo "Unexpected"
                ;;
    esac
    else
    ./menu.sh
fi