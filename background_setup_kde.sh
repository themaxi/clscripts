#/bin/sh
if [ "$EUID" -ne 0 ]
  then echo "ОШИБКА: нужны права root!"
  exit
fi
echo "Уствановим фон"
cp ./pgatu_back.jpg /usr/pgatu_back.jpg

echo "Обновляем конфигу темы"
echo "[General]
background=/usr/pgatu_back.jpg" >> /usr/share/sddm/themes/maldives/theme.conf.user



