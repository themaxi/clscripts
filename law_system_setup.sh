#/bin/sh
if [ "$EUID" -ne 0 ]
  then echo "ОШИБКА: нужны права root!"
  exit
fi

echo "Установим wine и winetricks"
emerge wine winetricks

echo "Установим архитектуру"
echo "export WINEARCH=win32" > ~/.bashrc

echo "Инициализируем wine"
WINEARCH=win32 wineboot

