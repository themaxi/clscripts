#/bin/sh
if [ "$EUID" -ne 0 ]
  then echo "ОШИБКА: нужны права root!"
  exit
fi

echo "Установим wine и winetricks"
emerge wine winetricks

