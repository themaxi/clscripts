#/bin/sh
if [ "$EUID" -ne 0 ]
  then echo "ОШИБКА: нужны права root!"
  exit
fi
echo "Настройка resolv"
echo "search pgatu  pgatu.lan
nameserver 192.168.2.8
#nameserver 192.168.2.226" > /etc/resolv.conf

echo "Добавим бинарные хосты"
read -e -p "Имена бинарных хостов[нажимаем Enter]: " -i "http://kdebinhost.pgatu.lan/packages http://xfcebinhost.pgatu.lan/packages http://dsslave.pgatu.lan/packages" binaryhost
echo "PORTAGE_BINHOST=\"$binaryhost\"" >> /etc/portage/make.conf/custom

echo "Запускаем обновление"
cl-update

echo "Добавим сервер времени"
echo "server dsmain.pgatu.lan" >> /etc/ntp.conf

echo "Запускаем службу времени"
/etc/init.d/ntp-client start
rc-update add ntp-client default

echo "Добавляем оверлей barzog-overlay"
layman -a barzog-overlay
echo "Добавляем оверлей yandex"
layman -a yandex
echo "Введите имя хоста:"
read vhostname
echo "Перезаписываем /etc/conf.d/hostname"
echo "hostname=\"$vhostname\"
rc_before=\"net.lo\"" > /etc/conf.d/hostname
echo "Перезаписываем /etc/hosts"
echo "127.0.0.1       $vhostname.pgatu.lan $vhostname localhost" > /etc/hosts

echo "Перезапустим хостнейм"
hostname "$vhostname"

echo "Обновляем uses"
echo ">=media-gfx/graphicsmagick-1.3.25 -imagemagick
>=net-fs/samba-4.8.1 acl addc addns ads client cluster cups fam gnutls ldap pam python syslog winbind -dmapi -gpg -iprint -quota (-selinux) (-system-heimdal) -system-mitkrb5 {-test} -zeroconf
>=sys-auth/sssd-1.16.0 samba
>=net-dns/bind-tools-9.11.2_p1 gssapi
>=net-nds/openldap-2.4.44 sasl abi_x86_32
>=dev-libs/cyrus-sasl-2.1.26-r9 kerberos
>=dev-libs/openssl-1.0.2o abi_x86_32" >> /etc/portage/package.use/custom

echo "Обновляем keywords"
echo "=sys-libs/tevent-0.9.36 ~amd64
=dev-util/cmocka-1.1.1 ~amd64
=sys-libs/talloc-2.1.13 ~amd64
=net-fs/samba-4.8.1 ~amd64
=sys-libs/tdb-1.3.15 ~amd64
=sys-libs/ldb-1.3.2 ~amd64
=sys-auth/sssd-1.16.0 ~amd64
>=www-client/yandex-browser-beta-18.3.1.1122_p1 ~amd64" >> /etc/portage/package.keywords/custom

echo "Установим bind-tools"
emerge bind-tools

echo "Установим samba"
emerge =samba-4.8.1

echo "Установим sssd"
emerge =sssd-1.16.0

echo "Установим Яндекс.Браузер"
emerge yandex-browser-beta

echo "Установим x11vnc"
emerge x11vnc

echo "Установим их запуск в default"
rc-update add samba default
rc-update add sssd default

echo "Настройка samba"
echo "[global]
workgroup = PGATU
client signing = yes
client use spnego = yes
kerberos method = secrets and keytab
realm = PGATU.LAN
security = ads
log level = 3
idmap_ldb:use rfc2307 = yes" > /etc/samba/smb.conf

echo "Настройка sssd"
echo "[sssd]
services = nss, pam
config_file_version = 2
domains = PGATU.LAN

[domain/PGATU.LAN]
id_provider = ad
auth_provider = ad
chpass_provider = ad
override_homedir = /home/%u
override_shell = /bin/bash
access_provider = simple

[nss]
debug_level = 1

[pam]
debug_level = 1" > /etc/sssd/sssd.conf

chmod og-r /etc/sssd/sssd.conf 

echo "Настройка kerberos"
echo "[libdefaults]
	default_realm = PGATU.LAN
	dns_lookup_realm = true
	dns_lookup_kdc = true

[realms]
	PGATU.LAN = {
		admin_server = dsmain.pgatu.lan
	}

[logging]
	kdc = CONSOLE" > /etc/krb5.conf

echo "Настройка nss"
echo "passwd:      files sss
shadow:      files sss
group:       files sss
hosts:       files dns sss
networks:    files dns sss
services:    files ldap sss
protocols:   files ldap sss
rpc:         db files sss
ethers:      db files sss
netmasks:    files sss
netgroup:    files sss
bootparams:  files sss
automount:   files sss
aliases:     files sss" > /etc/nsswitch.conf

echo "Настройка pam"
echo "auth        required      pam_env.so
auth        sufficient    pam_unix.so nullok try_first_pass
auth        requisite     pam_succeed_if.so uid >= 500 quiet
auth        sufficient    pam_sss.so use_first_pass
auth        required      pam_deny.so

account     required      pam_unix.so broken_shadow
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 500 quiet
account [default=bad success=ok user_unknown=ignore] pam_sss.so
account     required      pam_permit.so

password    requisite     pam_cracklib.so try_first_pass retry=3
password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok
password    sufficient    pam_sss.so use_authtok
password    required      pam_deny.so

session     required      pam_mkhomedir.so umask=0022 skel=/etc/skel/
session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     sufficient    pam_sss.so
session     required      pam_unix.so" > /etc/pam.d/system-auth

echo "Запустим samba"
/etc/init.d/samba restart

echo "Подключаемся к домену..."
kinit administrator
klist
sudo net ads join -k
/etc/init.d/sssd restart

echo "Настроим автоподмену доменных групп"
sss_override group-add linuxlocalvideo -g 27
sss_override group-add linuxlocalplugdev -g 440
sss_override group-add linuxlocalusers -g 100
sss_override group-add linuxlocalaudio -g 18
sss_override group-add linuxlocalcdrom -g 19
sss_override group-add linuxlocalfloppy -g 11
sss_override group-add linuxlocalcdrw -g 80
sss_override group-add linuxlocalscanner -g 441
sss_override group-add linuxlocalusb -g 85

echo "Запустим sssd"
/etc/init.d/sssd restart
echo "Внимательно смотрим вывод, если ничего не сломалось, то все хорошо =)"
