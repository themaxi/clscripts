#/bin/sh
if [ "$EUID" -eq 0 ]
  then echo "ОШИБКА: запускать от обычного пользователя!"
  exit
fi

echo "НЕ ЗАБЫВАЕм НАСТРОИТЬ СЕТЕВОЙ ДИСК в winecfg!"

cp ./conslink.desktop ~/Desktop/conslink.desktop
