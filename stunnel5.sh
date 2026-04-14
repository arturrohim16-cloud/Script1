#!/bin/bash
# ==========================================
# Script Stunnel5 Ultra Premium - AJI STORE
# ==========================================

# Warna Output Full
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

# Variabel Sertifikat (Mengikuti folder Xray)
cert_dir="/etc/xray"
domain=$(cat /etc/xray/domain)

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      MEMULAI INSTALASI STUNNEL 5 LENGKAP       ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 1. Update & Install Dependensi untuk Compile
echo -e "${ORANGE}[*] Installing dependencies...${NC}"
apt install -y build-essential libssl-dev openssl wget curl

# 2. Download dan Compile Stunnel 5.60 (Versi Stabil Terbaru)
echo -e "${ORANGE}[*] Downloading and Compiling Stunnel 5...${NC}"
cd /root
wget -q "https://raw.githubusercontent.com/arturrohim16-cloud/Script1/main/stunnel-5.60.tar.gz"
tar -xzf stunnel-5.60.tar.gz
cd stunnel-5.60
./configure
make
make install
# Pindahkan binary ke lokasi sistem
cp src/stunnel /usr/local/bin/stunnel
chmod +x /usr/local/bin/stunnel
cd /root
rm -rf stunnel-5.60*

# 3. Membuat Folder Konfigurasi
mkdir -p /etc/stunnel5
mkdir -p /var/run/stunnel5

# 4. Membuat File Konfigurasi stunnel5.conf (Ultra Full Port)
echo -e "${ORANGE}[*] Creating stunnel5.conf configuration...${NC}"
cat > /etc/stunnel5/stunnel5.conf << END
# Stunnel5 Configuration - AJI STORE PREMIUM
cert = ${cert_dir}/xray.crt
key = ${cert_dir}/xray.key
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear-ssl]
accept = 443
connect = 127.0.0.1:109

[openssh-ssl]
accept = 445
connect = 127.0.0.1:22

[stunnel_3]
accept = 447
connect = 127.0.0.1:77

[stunnel_4]
accept = 777
connect = 127.0.0.1:143

[stunnel_5]
accept = 990
connect = 127.0.0.1:109
END

# 5. Membuat Service Systemd untuk Stunnel5
echo -e "${ORANGE}[*] Creating systemd service...${NC}"
cat > /etc/systemd/system/stunnel5.service << END
[Unit]
Description=Stunnel5 Service AJI STORE
After=network.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/bin/stunnel /etc/stunnel5/stunnel5.conf
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
END

# 6. Mengatur Firewall (Buka semua port SSL)
echo -e "${ORANGE}[*] Opening Ports in Firewall...${NC}"
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -p tcp --dport 445 -j ACCEPT
iptables -I INPUT -p tcp --dport 447 -j ACCEPT
iptables -I INPUT -p tcp --dport 777 -j ACCEPT
iptables -I INPUT -p tcp --dport 990 -j ACCEPT
iptables-save > /etc/iptables.up.rules

# 7. Finishing - Restart & Status Check
echo -e "${ORANGE}[*] Tahap Finishing: Starting Stunnel5...${NC}"
systemctl daemon-reload
systemctl enable stunnel5
systemctl start stunnel5

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      INSTALASI STUNNEL 5 SELESAI (FULL)        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}  SSL Port 1 : 443 (Dropbear)${NC}"
echo -e "${PURPLE}  SSL Port 2 : 445 (OpenSSH)${NC}"
echo -e "${PURPLE}  SSL Port 3 : 447 (Stunnel 3)${NC}"
echo -e "${PURPLE}  SSL Port 4 : 777 (Stunnel 4)${NC}"
echo -e "${PURPLE}  SSL Port 5 : 990 (Stunnel 5)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${ORANGE}  Status: RUNNING (ON)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

