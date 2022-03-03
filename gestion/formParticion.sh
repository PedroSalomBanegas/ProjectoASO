. funciones/funciones.sh
function iniciarFormParticion() {
    disco=`ventanaSelecionarDisco`

    if [ "$disco" = "return" ]
    then
        ./menu.sh
        exit
    fi

    opcion=$(yad --list \
                    --title=MENU \
                    --height=220 \
                    --width=150 \
                    --button=Salir:1 \
                    --button=Seleccionar:0 \
                    --center \
                    --buttons-layout=spread \
                    --text-align=center \
                    --text="Formatear y Particionar \n Disco: $disco" \
                    --tree \
                    --column="Selecciona una opción:" \
                        "Añadir Particion" "Eliminar Particion" "Formatear" )
    ans=$?
    if [ $ans -eq 0 ]
    then
        #Recojo datos para luego mostrar en los dialogos de YAD
        lista=`discosConectados`
        listaYAD=`formatearStringYAD $lista`
        listaMKFS=`obtenerParticiones $disco`
        yadMKFS=`formatearStringYAD $listaMKFS`
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
                        #Cambiar "|" por " "
                        seleccion=`sed 's/|/ /g' test.txt`
                        #Crear partición
                        añadirParticion $disco $seleccion
                        rm test.txt
                        fecha=`date +%Y/%m/%d`
                        nombreParticion=`echo $disco | cut -d"/" -f3`
                        #Archivo Log
                        echo "AñadirParticion:${nombreParticion}:${fecha}" >> data/gestorDisco.log
                    else 
                        iniciarFormParticion
                    fi
                    ;;
                "Eliminar Particion")
                    listaCheck=`checklist $disco`
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
                    nombreParticion=`echo $disco | cut -d"/" -f3` 
                    if [ $ans -eq 0 ]
                    then  
                        #Borrar particiones
                        eliminarParticion ${eliminar}
                        fecha=`date +%Y/%m/%d`
                        #Archivo Log
                        echo "Eliminar_Particion:${nombreParticion}:${fecha}" >> data/gestorDisco.log
                    else
                        iniciarFormParticion
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
                        #Formateo
                        echo -e "s\n" | sudo mkfs.$seleccion
                        rm test.txt
                        #Datos para el archivo Log
                        #fileSys=`echo "$seleccion" | cut -d" " -f1` 
                        par=`echo "$seleccion" | cut -d" " -f2`
                        nombreParticion=`echo $seleccion | cut -d"/" -f3` 
                        fecha=`date +%Y/%m/%d`
                        echo "Formateo:${nombreParticion}:${fecha}" >> data/gestorDisco.log
                    else
                        iniciarFormParticion
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
