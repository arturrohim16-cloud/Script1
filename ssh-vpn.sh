#!/bin/bash
# ==========================================
# Core Engine SSH & OpenVPN - AJI STORE PREMIUM
# ==========================================

# Warna Output
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

# Getting IP
MYIP=$(wget -qO- ipinfo.io/ip);

# ==================================================
# Link Hosting GitHub AJI STORE
# ==================================================
ajivpn="raw.githubusercontent.com/arturrohim16-cloud/Script1/main/ssh"
ajivpnn="raw.githubusercontent.com/arturrohim16-cloud/Script1/main/xray"
ajivpnnn="raw.githubusercontent.com/arturrohim16-cloud/Script1/main/trojango"
ajivpnnnn="raw.githubusercontent.com/arturrohim16-cloud/Script1/main/stunnel5"
ajivpnnnnn="raw.githubusercontent.com/arturrohim16-cloud/Script1/main/update"
ajivpnnnnnn="raw.githubusercontent.com/arturrohim16-cloud/Script1/main/websocket"

# Initializing var
export DEBIAN_FRONTEND=noninteractive
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

# Detail Sertifikat
country=ID
state=Indonesia
locality=Indonesia
organization=AjiStore
organizationalunit=Premium
commonname=ajistore
email=ajistore@premium.com

cd

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
exit 0
END

chmod +x /etc/rc.local
systemctl enable rc-local
systemctl start rc-local.service

# Disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# Update & Purge
apt update -y
apt upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y

# Install Requirements Tools
apt -y install wget curl net-tools ruby python make cmake coreutils rsyslog zip unzip nano sed gnupg gnupg1 bc jq apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof libsqlite3-dev libz-dev gcc g++ libreadline-dev zlib1g-dev libssl-dev dos2unix

# Set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Install Webserver (Nginx)
apt -y install nginx php php-fpm php-cli php-mysql
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
curl https://raw.githubusercontent.com/arturrohim16-cloud/Master/refs/heads/main/ssh/nginx.conf > /etc/nginx/nginx.conf
curl https://${ajivpn}/vps.conf > /etc/nginx/conf.d/vps.conf
sed -i 's/listen = \/var\/run\/php-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php/fpm/pool.d/www.conf
useradd -m vps;
mkdir -p /home/vps/public_html
echo "<?php phpinfo() ?>" > /home/vps/public_html/info.php
chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html
wget -O /home/vps/public_html/index.html "https://${ajivpn}/index.html1"
/etc/init.d/nginx restart

# Install Badvpn UDPGW
wget -O /usr/bin/badvpn-udpgw "https://${ajivpn}/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500' /etc/rc.local
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500

# Setting Port SSH & Port 80
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 80' /etc/ssh/sshd_config
sed -i '/Port 80/a Port 2253' /etc/ssh/sshd_config
echo "Port 42" >> /etc/ssh/sshd_config
/etc/init.d/ssh restart

# Install Dropbear
apt -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 1153 -p 80"/g' /etc/default/dropbear
/etc/init.d/dropbear restart

# Install SSLH
apt -y install sslh
cat > /etc/default/sslh <<-END
RUN=yes
DAEMON=/usr/sbin/sslh
DAEMON_OPTS="--user sslh --listen 0.0.0.0:443 --ssl 127.0.0.1:777 --ssh 127.0.0.1:109 --openvpn 127.0.0.1:1194 --http 127.0.0.1:8880 --pidfile /var/run/sslh/sslh.pid -n"
END
service sslh restart

# Install Stunnel 5
cd /root/
wget -q -O stunnel5.zip "https://${ajivpnnnn}/stunnel5.zip"
unzip -o stunnel5.zip
cd /root/stunnel
chmod +x configure
./configure && make && make install
cd /root
rm -r -f stunnel
rm -f stunnel5.zip
mkdir -p /etc/stunnel5

cat > /etc/stunnel5/stunnel5.conf <<-END
cert = /etc/xray/xray.crt
key = /etc/xray/xray.key
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
[dropbear]
accept = 445
connect = 127.0.0.1:109
[openssh]
accept = 777
connect = 127.0.0.1:443
[openvpn]
accept = 990
connect = 127.0.0.1:1194
END

# Service Stunnel5
cat > /etc/systemd/system/stunnel5.service << END
[Unit]
Description=Stunnel5 Service AJI STORE
After=syslog.target network-online.target
[Service]
ExecStart=/usr/local/bin/stunnel5 /etc/stunnel5/stunnel5.conf
Type=forking
[Install]
WantedBy=multi-user.target
END
systemctl enable stunnel5
systemctl restart stunnel5

# OpenVPN
wget https://${ajivpn}/vpn.sh && chmod +x vpn.sh && ./vpn.sh

# Banner
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear
wget -O /etc/issue.net "https://${ajivpn}/issue.net"

# Download Scripts Management (Finishing)
cd /usr/bin
wget -O addhost "https://${ajivpn}/addhost.sh"
wget -O slhost "https://${ajivpn}/slhost.sh"
wget -O menu "https://${ajivpnnnnn}/menu.sh"
wget -O addssh "https://${ajivpn}/addssh.sh"
wget -O delssh "https://${ajivpn}/delssh.sh"
wget -O cekssh "https://${ajivpn}/cekssh.sh"
wget -O renewssh "https://${ajivpn}/renewssh.sh"
wget -O addvmess "https://${ajivpnn}/addv2ray.sh"
wget -O addvless "https://${ajivpnn}/addvless.sh"
wget -O addtrojan "https://${ajivpnn}/addtrojan.sh"
wget -O addgrpc "https://${ajivpnn}/addgrpc.sh"
wget -O running "https://${ajivpnnnnn}/running.sh"

chmod +x *
cd

# Penjadwalan Auto-Reboot & Clear Log
echo "0 5 * * * root clearlog && reboot" >> /etc/crontab
echo "0 0 * * * root xp" >> /etc/crontab

# Finishing
apt autoremove -y
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/stunnel5 restart
history -c
clear
echo -e "${GREEN}INSTALASI SSH-VPN BERHASIL SELESAI!${NC}"
