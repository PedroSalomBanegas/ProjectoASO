opcion=$(yad --list \
                 --title="MENU" \
                 --height=220 \
                 --width=150 \
                 --button=Salir:1 \
                 --button=Seleccionar:0 \
                 --center \
                 --text="MENU PRINCIPAL" \
                 --tree \
                 --column="Selecciona una opción:" \
                    "Gestionar disco" "Formatear y Particionar" "Estado de discos" "Estadísticas de uso" "Ayuda")
ans=$?
if [ $ans -eq 0 ]
then
    case $opcion in
    #NO SE PORQUE SE AÑADE UNA " | " EN $OPCION
    #CAMBIAR ECHOS POR LOS NOMBRES DEL LOS SCRIPTS
            "Gestionar disco|")
                echo "Gestionar"
                ;;
            "Formatear y Particionar|")
                echo "Formatear"
                ;;
            "Estado de discos|")
                echo "Estado"
                ;;
            "Estadísticas de uso|")
                echo "Estadísticas"
                ;;
            "Ayuda|")
                echo "Ayuda"
                ;;
            *)
                echo "Unexpected"
                ;;
    esac
else
    echo "No has elegido ninguna opcion"
fi