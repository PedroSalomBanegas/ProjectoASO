. funciones.sh
function checklist() {
    string=`obtenerParticiones /dev/sd\?`
    cont=0
    stringTotal=""
    long=${#string}

    #while [ 5 -lt $long ]
    #do
    let cont=cont+1
    echo $string
    pos=`expr index "$string" " "` 
    stringGuardar=`expr substr "$string" 1 $pos`
    echo $pos
    echo $stringGuardar
    nuevoString=`expr substr "$string" $pos $long`
    
    stringTotal="${stringTotal} ${cont} ${stringGuardar}"
    string=$nuevoString
    long=${#string}
    #done

    #VUELTA 2
    let cont=cont+1
    echo $string
    pos=`expr index "$string" " "` 
    stringGuardar=`expr substr "$string" 1 $pos`
    echo $pos
    echo $stringGuardar
    nuevoString=`expr substr "$string" $pos $long`
    stringTotal="${stringTotal} ${cont} ${stringGuardar}"
    string=$nuevoString
    long=${#string}
    #echo $stringTotal
    #echo $string
    #echo $long

}

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
                    "Añadir Particion" "Eliminar Particion" "Formatear" )
ans=$?
if [ $ans -eq 0 ]
then
    lista=`discosConectados`
    listaYAD=`formatearStringYAD $lista`
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
            *)
                echo "Unexpected"
                ;;
    esac
    else
    ./menu.sh
fi