#/bin/sh
if [ "$EUID" -eq 0 ]
  then echo "ОШИБКА: запускать от обычного пользователя!"
  exit
fi

cp ./conslink.desktop ~/Desktop/conslink.desktop
