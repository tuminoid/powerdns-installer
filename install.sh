#!/bin/sh -e

MYSQL_ROOT_PASS="pass"
PDNS_ADMIN_PASS="admin"
export DEBIAN_FRONTEND=noninteractive

# preinstalls
apt-get -y update
apt-get -y install git debconf-utils sed

# pdns itself
echo "mysql-server-5.5 mysql-server/root_password_again password $MYSQL_ROOT_PASS" | debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password password $MYSQL_ROOT_PASS" | debconf-set-selections
apt-get -y install pdns-server mysql-server mysql-client
cat <<EOF | mysql -u root --password=$MYSQL_ROOT_PASS
CREATE DATABASE powerdns;
GRANT ALL ON powerdns.* TO 'power_admin'@'localhost' IDENTIFIED BY '$PDNS_ADMIN_PASS';
GRANT ALL ON powerdns.* TO 'power_admin'@'localhost.localdomain' IDENTIFIED BY '$PDNS_ADMIN_PASS';
FLUSH PRIVILEGES;

USE powerdns;
CREATE TABLE domains (
  id INT auto_increment,
  name VARCHAR(255) NOT NULL,
  master VARCHAR(128) DEFAULT NULL,
  last_check INT DEFAULT NULL,
  type VARCHAR(6) NOT NULL,
  notified_serial INT DEFAULT NULL,
  account VARCHAR(40) DEFAULT NULL,
  primary key (id)
);
CREATE UNIQUE INDEX name_index ON domains(name);

CREATE TABLE records (
  id INT auto_increment,
  domain_id INT DEFAULT NULL,
  name VARCHAR(255) DEFAULT NULL,
  type VARCHAR(6) DEFAULT NULL,
  content VARCHAR(255) DEFAULT NULL,
  ttl INT DEFAULT NULL,
  prio INT DEFAULT NULL,
  change_date INT DEFAULT NULL,
  primary key(id)
);
CREATE INDEX rec_name_index ON records(name);
CREATE INDEX nametype_index ON records(name,type);
CREATE INDEX domain_id ON records(domain_id);

CREATE TABLE supermasters (
  ip VARCHAR(25) NOT NULL,
  nameserver VARCHAR(255) NOT NULL,
  account VARCHAR(40) DEFAULT NULL
);
EOF

sed -i 's,# launch=,launch=gmysql,' /etc/powerdns/pdns.conf
cat <<EOF >/etc/powerdns/pdns.d/pdns.local
gmysql-host=127.0.0.1
gmysql-user=power_admin
gmysql-password=$PDNS_ADMIN_PASS
gmysql-dbname=powerdns
EOF

service pdns restart


# poweradmin
apt-get -y install apache2 mysql-server mysql-client libapache2-mod-php5 php5 php5-common php5-curl php5-dev php5-gd php-pear php5-imap php5-mcrypt php5-mhash php5-ming php5-mysql php5-xmlrpc gettext
pear install DB
pear install pear/MDB2#mysql
service apache2 restart

cd /var/www
git clone https://github.com/poweradmin/poweradmin.git
chown -R www-data:www-data /var/www/poweradmin

# done
echo "Install complete! Now surf to localhost/poweradmin/install/index.php and configure your stuff!"

