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
    #Autor: Pedro
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
    #Autor: Pedro
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

function particionExisteFstab() {
    local existe=`cat /etc/fstab | grep -v "#" | grep "$1"`
    if [ "$existe" != "" ]
        then
            echo "true"
        else
            echo "false"
    fi
}

function formatearStringYAD(){
    #Autor: Pedro
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

function formatearStringListaYAD() {
    #Autor: Jaime
    array=($@) #Recoger un array desde un parámetro
    for str in ${array[@]}
        do
            #echo $stringConvertidaLista
            if [ -z "${stringConvertidaLista}" ]
                then
                    stringConvertidaLista="$str" #se crea la variable
                else
                    stringConvertidaLista="${stringConvertidaLista} $str"
            fi
        done
        echo ${stringConvertidaLista}
        stringConvertidaLista=""
}

function añadirParticion() {
    #Autor: Jaime
    nombrePar=$1
    tamano=$2
    if [ $3 = "Primaria" ]
        then
            tipo="p"
        else
            tipo="e"
        fi
    echo -e "n\n${tipo}\n\n\n+${tamano}M\nw\n" | sudo fdisk ${nombrePar}
}

function eliminarParticion2() {
    #Autor: Jaime
    string=$*
    long=${#string} #recojo la longitud
    #echo $*
    pos=`expr index "$string" "|"`
    while [ 0 -ne $long ]
        do
        pos=`expr index "$string" "|"` #posicion del separador
        let pos=pos+1 
        nuevoString=`expr substr "$string" $pos $long`
        #guardo la particion
        posGuardar=`expr index "$nuevoString" "|"`
        let posGuardar=posGuardar-1
        particion=`expr substr "$nuevoString" 1 $posGuardar`
        echo $particion
        if [ $particion = "/dev/*" ]
            then
                echo "-->"$particion
                #echo "EliminarParticion:${particion}:${fecha}" >> formParticion.log
                #device=${particion::\-1}
                #posNum=${particion: -1}
                #echo -e "d\n${posnum}\nw\n" | sudo fdisk $device
            fi
        string=$nuevoString
        long=${#string}
        done
}

function eliminarParticion() {
    #Autor: Jaime
    string=$*
    fecha=`date +%d/%m/%Y`
    IFS="|" read -r -a array <<< "$string"
    for str in ${array[@]}
        do
            if [ $str != "TRUE" ]
                then
                    echo "EliminarParticion:${str}:${fecha}" >> formParticion.log
                    device=${str:: -1}
                    posNum=${str: -1}
                    echo -e "d\n${posnum}\nw\n" | sudo fdisk $device
            fi
        done
}

function checklist() {
    #Autor: Jaime
    #No implementado
    string=`obtenerParticiones $1`
    cont=1
    prueba=`echo "$string" | cut -d" " -f${cont}`
    while [ "$prueba" != "" ]
        do
            
            if [ -z "$stringTotal" ]
                then
                    stringTotal="$cont $prueba"
                else
                    stringTotal="$stringTotal $cont $prueba"
                fi
                let cont=cont+1
            prueba=`echo "$string" | cut -d" " -f${cont}`
        done
        echo $stringTotal
}
     