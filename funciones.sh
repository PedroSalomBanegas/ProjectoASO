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
}

function ventanaSelecionarDisco() {
    #Autor: Pedro
    discosConectados #Actualiza el array con los discos conectados (no retornarlo para poder utilizar los índices)
    for disco in "${listaDiscos[@]}" #Formatear el array en una string aceptada por YAD
        do
            if [ -z ${discosStr} ]
                then
                    discosStr="$disco"
                else
                    discosStr="${discosStr}!$disco"
            fi
        done

        seleccion=$(yad --form \
            --title="Selección disco" \
            --text="Escoge el disco a operar" \
            --center \
            --field="Disponibles: ":CB "$discosStr")
    
    ans=$? #respuesta del usuario
    if [ $ans -eq 0 ]
    then
        
        IFS="|" read -r -a array <<< "$seleccion" #Recoger los datos y guardarlos en un array

        echo "Se ha seleccionado el disco ${array[0]}"
    else
        echo "Se ha cancelado la operación"
    fi

}