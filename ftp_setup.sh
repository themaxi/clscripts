#/bin/sh
if [ "$EUID" -ne 0 ]
  then echo "ОШИБКА: нужны права root!"
  exit
fi
echo "Установим vsftpd"
emerge vsftpd

echo "Создадим конфигу"
echo "anonymous_enable=NO
local_enable=YES
write_enable=YES
anon_mkdir_write_enable=NO
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
listen=YES" > /etc/vsftpd/vsftpd.conf

echo "Создаем папку /ftpfiles"
mkdir /ftpfiles
chown ftp /ftpfiles
chmod oug+rwx /ftpfiles

rc-update add vsftpd
/etc/init.d/vsftpd restart

