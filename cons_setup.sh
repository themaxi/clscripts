#/bin/sh
if [ "$EUID" -ne 0 ]
  then echo "ОШИБКА: нужны права root!"
  exit
fi

echo "Установка КонсультантПлюс"
read -e -p "Путь к общей папке с К+: " -i "//sdc02.psaa.local/Consultant" conssmb
read -e -p "Путь к папке монтирования: " -i "/mnt/cons" localmount
read -e -p "Имя пользователя: " -i "melehin-mi" username
read -e -p "Пароль: " -i "" userpwd
read -e -p "Версия samba: " -i "1.0" sambaverion

mkdir $localmount

echo "$conssmb $localmount cifs username=$username,pass=$userpwd,dir_mode=0777,file_mode=0777,vers=$sambaverion" >> /etc/fstab

mount -a
