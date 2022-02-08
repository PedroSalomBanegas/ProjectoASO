. funciones.sh

opcion=$(yad --list \
                 --title="MENU" \
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
    listaMKFS=`obtenerParticiones /dev/sd\?`
    yadMKFS=`formatearStringYAD $listaMKFS`
    opcion=${opcion::-1} #Quita el | del final
    case $opcion in
            "Añadir Particion")
                part=$(yad --form \
                --height=220 \
                --width=150 \
                --button=Salir:1 \
                --button=Seleccionar:0 \
                --title="MENU" \
                --center \
                --field="Particiones":CB \
                ${listaYAD} \
                --field="Tamaño MB":CB \
                '10000!20000!30000' \
                --field="Tipo":CB \
                'Primaria!Extendida' )
                ans=$?
                if [ $ans -eq 0 ]
                then
                    echo ${part} > test.txt 
                    seleccion=`sed 's/|/ /g' test.txt`
                    añadirParticion $seleccion
                    rm test.txt
                else
                    echo "Has salido"
                fi
                ;;
            "Eliminar Particion")
                eliminar=$(yad --list \
                --title="MENU" \
                --height=200 \
                --width=250 \
                --center \
                --button=Salir:1 \
                --button=Seleccionar:0 \
                --text="Selecciona particiones a eliminar:" \
                --checklist \
                --column="" \
                --column="Partciciones del sistema" \
                1 "/dev/sdb1" 2 "/dev/sdb2" 3 "/dev/sdb3" )
                ans=$?
                if [ $ans -eq 0 ]
                then  
                    eliminarParticion ${eliminar}
                else
                    checklist
                    echo "nada"
                fi
                ;; 
            "Formatear")
                formateo=$(yad --form \
                --height=220 \
                --width=150 \
                --button=Salir:1 \
                --button=Seleccionar:0 \
                --title="MENU" \
                --center \
                --field="Formato":CB \
                'ext3!ext4'\
                --field="Partición a formatear":CB \
                ${yadMKFS} )
                ans=$?
                if [ $ans -eq 0 ]
                then  
                    echo ${formateo} > test.txt 
                    seleccion=`sed 's/|/ /g' test.txt` #intercambia | por " "
                    mkfsBetter $seleccion
                    rm test.txt
                else
                    echo "nada"
                fi
                ;;   
            *)
                echo "Unexpected"
                ;;
    esac
    else
    ./menu.sh
fi