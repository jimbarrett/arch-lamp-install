#!/bin/sh

echo "installing packages..."
pacman --no-confirm --needed -S apache php php-apache mariadb composer >/dev/null 2>&1

echo "setting up db..."
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

echo "updating .conf..."
awk '{
	if ($NF ~ /mod_unique_id/)
		$0="#"$0
	if ($NF ~ /mod_mpm_event/)
		$0="#"$0
	print
}' /etc/httpd/conf/httpd.conf > newhttpd

echo "LoadModule mpm_prefork_module modules/mod_mpm_prefork.so" >> newhttpd
echo "LoadModule php_module modules/libphp.so" >> newhttpd
echo "AddHandler php-script .php" >> newhttpd
echo "Include conf/extra/php_module.conf" >> newhttpd

systemctl enable httpd
systemctl enable mariadb

clear
echo "Installation complete. Don't forget to run mysql_secure_installation."

