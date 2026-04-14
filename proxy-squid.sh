#!/bin/bash
# ==========================================
# Script Squid Proxy Super Full - AJI STORE
# ==========================================

# Warna Output Full & Mewah
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

# Mengambil Data IP VPS
MYIP=$(wget -qO- ipinfo.io/ip);

echo -e "${CYAN}Memulai Instalasi Squid Proxy Super Full Port...${NC}"

# 1. Update dan Install Squid
apt-get update
apt-get install -y squid

# 2. Membuat Konfigurasi Utama squid.conf (Super Full)
cat > /etc/squid/squid.conf << END
# ACL (Access Control List)
acl manager proto cache_object
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1

# Izin Akses untuk IP VPS Anda (Sangat Penting)
acl SSH src $MYIP/32

# Port yang diizinkan (Lengkap untuk semua kebutuhan tunneling)
acl SSL_ports port 443
acl SSL_ports port 992
acl SSL_ports port 990
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

# Aturan Akses (Hanya izinkan VPS dan Local)
http_access allow SSH
http_access allow localhost
http_access deny all

# --- DAFTAR PORT SQUID LENGKAP ---
http_port 3128
http_port 8080
http_port 8000
http_port 8888
http_port 2082
http_port 2086
http_port 2095
# --------------------------------

# Pengaturan Cache (Ringan agar tidak memakan RAM)
coredump_dir /var/spool/squid
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320

# Branding Nama Server Anda
visible_hostname AJI-STORE-PREMIUM
END

# 3. Menjalankan Service Squid
systemctl stop squid
systemctl start squid
systemctl enable squid
systemctl restart squid

# 4. Pengaturan Firewall (Membuka Semua Port yang Ditambahkan)
echo -e "${ORANGE}Membuka Semua Port Proxy di Firewall...${NC}"
iptables -I INPUT -p tcp --dport 3128 -j ACCEPT
iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
iptables -I INPUT -p tcp --dport 8888 -j ACCEPT
iptables -I INPUT -p tcp --dport 2082 -j ACCEPT
iptables -I INPUT -p tcp --dport 2086 -j ACCEPT
iptables -I INPUT -p tcp --dport 2095 -j ACCEPT

# Simpan Iptables agar tidak hilang saat reboot
iptables-save > /etc/iptables.up.rules

echo -e "${GREEN}Instalasi Squid Proxy Super Full Berhasil!${NC}"
echo -e "${PURPLE}Port Aktif: 3128, 8080, 8000, 8888, 2082, 2086, 2095${NC}"

