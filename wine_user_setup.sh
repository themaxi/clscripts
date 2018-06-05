#/bin/sh
if [ "$EUID" -eq 0 ]
  then echo "ОШИБКА: запускать от обычного пользователя!"
  exit
fi

echo "Установим архитектуру"
echo "export WINEARCH=win32" > ~/.bashrc

echo "Инициализируем wine"
WINEARCH=win32 wineboot
