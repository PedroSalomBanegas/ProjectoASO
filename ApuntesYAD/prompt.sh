texto="¿<span weight=\"bold\" foreground=\"green\">Seguro</span> que quieres?"
yad --title="https://atareao.es" \
    --image=gtk-info \
    --width=250 \
    --height=80 \
    --button=Continuar:0 \
    --button=Abandonar:1 \
    --button=Patata:xd \
    --center \
    --text-align=center \
    --text="${texto}"
ans=$?
if [ $ans -eq 0 ]
then
    echo "Si que quiere continuar"
else
    echo "No quiere continuar"
fi