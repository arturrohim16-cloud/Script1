#!/bin/bash
# ==========================================
# Script SSH, Dropbear, Stunnel & BBR - AJI STORE
# ==========================================

# Warna untuk output
green='\e[1;32m'
NC='\e[0m'

echo -e "${green}Memulai Instalasi Mesin SSH & Akselerasi BBR...${NC}"

# 1. Update & Install Tools Dasar
apt update
apt install -y dropbear stunnel4 squid bzip2 gzip coreutils screen

# 2. Konfigurasi Dropbear (Port 109 & 143)
echo -e "${green}Mengatur Dropbear...${NC}"
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i '/DROPBEAR_EXTRA_ARGS=/c\DROPBEAR_EXTRA_ARGS="-p 109"' /etc/default/dropbear
systemctl restart dropbear

# 3. Konfigurasi Stunnel5/4 (Port 443 & 445)
echo -e "${green}Mengatur Stunnel (SSH-TLS)...${NC}"
cat > /etc/stunnel/stunnel.conf <<EOF
pid = /var/run/stunnel.pid
cert = /etc/xray/xray.crt
key = /etc/xray/xray.key
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:143

[dropbear-ssl]
accept = 445
connect = 127.0.0.1:109
EOF
systemctl restart stunnel4

# 4. Konfigurasi Squid Proxy (Port 3128 & 8080)
echo -e "${green}Mengatur Squid Proxy...${NC}"
MYIP=$(wget -qO- ipinfo.io/ip);
cat > /etc/squid/squid.conf <<EOF
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
acl SSH dst $MYIP-$MYIP/32
http_access allow SSH
http_access allow localhost
http_access deny all
http_port 3128
http_port 8080
coredump_dir /var/spool/squid
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
EOF
systemctl restart squid

# 5. Aktivasi BBR (TCP Speed Optimizer)
echo -e "${green}Mengaktifkan TCP BBR...${NC}"
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 6. Set Izin Akses Login SSH
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells

echo -e "${green}Instalasi SSH-VPN Selesai!${NC}"

