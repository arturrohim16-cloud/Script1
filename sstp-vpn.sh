#!/bin/bash
# ==========================================
# Script SSTP VPN Premium - AJI STORE
# ==========================================

# Warna untuk output agar rapi
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

# Variabel Utama
MYIP=$(wget -qO- ipinfo.io/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NIC=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

echo -e "${CYAN}Memulai Instalasi SSTP VPN Server...${NC}"

# 1. Install Dependensi yang Dibutuhkan
apt update
apt-get install -y cmake libpcre3-dev libssl-dev libsqlite3-dev libreadline-dev

# 2. Download dan Compile Accel-PPP (Mesin Utama SSTP)
cd /usr/bin
wget -O sstp "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/ssh/sstp.sh" # Ini hanya installer pendukung
chmod +x sstp

# Membuat Direktori Konfigurasi
mkdir -p /etc/accel-ppp
mkdir -p /var/log/accel-ppp

# 3. Membuat Konfigurasi Utama accel-ppp.conf
cat > /etc/accel-ppp.conf << END
[modules]
log_file
sstp
ippool
pppd_compat
auth_mschap_v2

[core]
log-error=/var/log/accel-ppp/core.log
thread-count=4

[common]
# Menggunakan DNS Google
sid=1
single-session=replace
check-interval=0
max-sessions=1000

[sstp]
verbose=1
# Port standar SSTP yang diminta
port=444
# Menggunakan sertifikat Xray yang sudah ada
cert=/etc/xray/xray.crt
key=/etc/xray/xray.key
hash-algo=sha1
timeout=60

[ippool]
# Range IP internal untuk client SSTP
gw-ip-address=192.168.100.1
192.168.100.2-255

[auth]
# Method enkripsi
any-login=0
noauth=0

[log]
log-file=/var/log/accel-ppp/accel-ppp.log
log-emerg=/var/log/accel-ppp/emerg.log
log-fail-pass=1
copy=1
level=3

[pppd-compat]
# Memastikan kompatibilitas dengan sistem login linux
ip-up=/etc/ppp/ip-up
ip-down=/etc/ppp/ip-down
radattr-prefix=/var/run/radattr
verbose=1
END

# 4. Membuat Service Systemd agar SSTP jalan otomatis
cat > /etc/systemd/system/sstp.service << END
[Unit]
Description=SSTP Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/accel-pppd -d -p /var/run/accel-pppd.pid -c /etc/accel-ppp.conf
PIDFile=/var/run/accel-pppd.pid
Restart=always

[Install]
WantedBy=multi-user.target
END

# 5. Mengatur Firewall IPTables untuk SSTP
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 444 -j ACCEPT
iptables -I FORWARD -s 192.168.100.0/24 -j ACCEPT
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o $NIC -j MASQUERADE
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# 6. Menjalankan Service
systemctl daemon-reload
enable sstp
systemctl start sstp
systemctl restart sstp

echo -e "${GREEN}Instalasi SSTP VPN Selesai pada Port 444!${NC}"

