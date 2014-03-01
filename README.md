powerdns-installer
==================

Installer for PowerDNS and Poweradmin for DNS server setup.

Just provision the Vagrant VM with `vagrant up` or run it in live server as root.
Modify some configs in beginning of `install.sh` file.

Additional information
==================
SSH
Port:     2222
Username: vagrant
Password: vagrant

Apache2 port: 40080

Proceed with the installation:
http://localhost:40080/poweradmin/install/

MySQL needed in Step3 of the installer:
Host: 127.0.0.1
DB: powerdns
User: power_admin
Pass: admin
