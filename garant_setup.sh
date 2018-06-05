#/bin/sh
if [ "$EUID" -ne 0 ]
  then echo "ОШИБКА: нужны права root!"
  exit
fi

echo "Установка ГАРАНТ"
read -e -p "Путь к общей папке с Гарантом: " -i "//sils02.psaa.local/GarantClient" garantsmb
read -e -p "Путь к папке монтирования: " -i "/mnt/garant" localmount
read -e -p "Имя пользователя: " -i "tomilov-dv" username
read -e -p "Пароль: " -i "" userpwd
read -e -p "Версия samba: " -i "1.0" sambaverion

mkdir $localmount
echo -e "\n" >> /etc/fstab
echo "$garantsmb $localmount cifs username=$username,pass=$userpwd,dir_mode=0777,file_mode=0777,vers=$sambaverion" >> /etc/fstab

mount -a
