componente=$(yad --list \
                 --title="https://atareao.es" \
                 --height=200 \
                 --width=250 \
                 --center \
                 --button=Aceptar:0 \
                 --button=Cancelar:1 \
                 --text="Selecciona un componente para tu pizza:" \
                 --column="" \
                 --column="Componente" \
                 --column="Calorías" \
                 1 "Jamón" 100 2 "Queso" 150 3 "Huevo" 125)
ans=$?
if [ $ans -eq 0 ]
then
    echo "Has elegido: ${componente}"
else
    echo "No has elegido ningún componente"
fi