. gestionDisco.sh
. estadoDisco.sh
. formParticion.sh
. estadisticaUso.sh

opcion=$(yad --list \
                 --title="MENU" \
                 --height=220 \
                 --width=150 \
                 --button=Salir:1 \
                 --button=Seleccionar:0 \
                 --center \
                 --buttons-layout=spread \
                 --text-align=center \
                 --text="MENU PRINCIPAL" \
                 --tree \
                 --column="Selecciona una opción:" \
                    "Gestionar disco" "Formatear y Particionar" "Estado de discos" "Estadísticas de uso")
ans=$?
if [ $ans -eq 0 ]
then
    opcion=${opcion::-1} #Quita el | del final
    case $opcion in
            "Gestionar disco")
                iniciarGestionDisco
                ;;
            "Formatear y Particionar")
                iniciarFormParticion
                ;;
            "Estado de discos")
                iniciarEstadoDisco
                ;;
            "Estadísticas de uso")
                generarFormularioLogs
                ;;
            "Ayuda")
                echo "Ayuda"
                ;;
            *)
                echo "Unexpected"
                ;;
    esac
else
    echo "No has elegido ninguna opcion"
fi