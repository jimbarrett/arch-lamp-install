#!/bin/sh

echo "installing packages..."
yes | pacman -S apache php php-apache mariadb composer &&

echo "setting up db..." &&
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql &&

echo "updating .conf..." &&
awk '{
	if ($NF ~ /mod_unique_id/)
		$0="#"$0
	if ($NF ~ /mod_mpm_event/)
		$0="#"$0
	print
}' /etc/httpd/conf/httpd.conf > newhttpd &&

echo "LoadModule mpm_prefork_module modules/mod_mpm_prefork.so" >> newhttpd &&
echo "LoadModule php_module modules/libphp.so" >> newhttpd &&
echo "AddHandler php-script .php" >> newhttpd &&
echo "Include conf/extra/php_module.conf" >> newhttpd &&

chgrp -R http /srv/http &&
chmod -R g+w /srv/http&&

systemctl start httpd &&
systemctl enable httpd &&
systemctl start mariadb &&
systemctl enable mariadb &&

clear
echo "Installation complete. Don't forget to run mysql_secure_installation and add your user to the http group "
echo "usermod -a -G http <your-user>"

