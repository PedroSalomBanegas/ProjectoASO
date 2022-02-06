. funciones.sh

function mkfsBetter () {
    formato=$1
    particion=$2
    mkfs.$1 $2
}

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
                    "Particionar" "Formatear" "Modificar partición" )
ans=$?
if [ $ans -eq 0 ]
then
    lista=`obtenerParticiones /dev/sd`
    listaYAD=`formatearStringYAD $lista`
    opcion=${opcion::-1} #Quita el | del final
    case $opcion in
            "Particionar")
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
                ${listaYAD} )
                ans=$?
                if [ $ans -eq 0 ]
                then  
                    echo ${formateo} > test.txt 
                    seleccion=`sed 's/|/ /g' test.txt`
                    mkfsBetter $seleccion
                    rm test.txt
                else
                    echo "nada"
                fi
                ;;   
            "Modificar partición")
                
                ;;
            *)
                echo "Unexpected"
                ;;
    esac
fi