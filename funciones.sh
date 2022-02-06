function discosConectados(){
    #Autor: Pedro
    ls /dev/sd? > discos #Recoger los discos conectados
    totalDiscos=`wc -l discos | cut -d" " -f1` #contar la cantidad de discos
    
    i=1 #Se necesita inicializar en 1 para que el head funcione correctamente
    listaDiscos=() #Inicializar array

    while [ ${i} -le ${totalDiscos} ]
        do
            #cat discos | head -n$i | tail -n1
            listaDiscos+=(`cat discos | head -n$i | tail -n1`) #Añadir los discos al Array
            i=`expr $i + 1`
        done
    echo ${listaDiscos[@]}
}

function obtenerParticiones() {
    ls $1?* > particiones #Únicamente recoge las particiones
    totalParticiones=`wc -l particiones | cut -d" " -f1` #contar la cantidad de particiones
    
    i=1 #Se necesita inicializar en 1 para que el head funcione correctamente
    listaParticiones=() #Inicializar array

    while [ ${i} -le ${totalParticiones} ]
        do
            #cat discos | head -n$i | tail -n1
            listaParticiones+=(`cat particiones | head -n$i | tail -n1`) #Añadir los discos al Array
            i=`expr $i + 1`
        done
    echo ${listaParticiones[@]}
}

function ventanaMontarDiscoFormulario() {
    listaParticiones=`obtenerParticiones $1` #Actualiza el array con las particiones del disco selecionado (no retornarlo para poder utilizar los índices)
    #echo $listaParticiones
    #formatearStringYAD ${listaParticiones}
    strParticiones=`formatearStringYAD ${listaParticiones}`
    
    local datos=$(yad --form \
    --title="Formulario Montar partición" \
    --text="¿Qué partición quieres montar?" \
    --center \
    --buttons-layout=spread \
    --field="Partición: ":CB \
    --field="Punto montaje" \
    "${strParticiones}" '/mnt')

    echo ${datos}
}

function ventanaSelecionarDisco() {
    #Autor: Pedro
    listaDiscos=`discosConectados` #Actualiza el array con los discos conectados (no retornarlo para poder utilizar los índices)
    strDiscos=`formatearStringYAD ${listaDiscos}`

        seleccion=$(yad --form \
            --title="Selección disco" \
            --text="Escoge el disco a operar" \
            --center \
            --buttons-layout=spread \
            --field="Disponibles: ":CB "$strDiscos")
    
    ans=$? #respuesta del usuario
    if [ $ans -eq 0 ]
    then
    
        IFS="|" read -r -a array <<< "$seleccion" #Recoger los datos y guardarlos en un array

        echo ${array[0]}
    else
        echo "return"
    fi

}

function formatearStringYAD(){
    local array=($@) #Recoger un array desde un parámetro
    #echo ${array[@]}
    for str in "${array[@]}" #Formatear el array en una string aceptada por YAD
        do
            if [ -z ${stringConvertida} ]
                then
                    stringConvertida="$str"
                else
                    stringConvertida="${stringConvertida}!$str"
            fi
        done
        echo ${stringConvertida}
        stringConvertida=""
}

function añadirParticion() {
    nombrePar=$1
    tamano=$2
    if [ $3 = "Primaria" ]
        then
            tipo="p"
        else
            tipo="e"
        fi
    echo "o\nn\n${tipo}\n3\n\\${tamano}\nw" | fdisk ${nombrePar}
}