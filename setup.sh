#!/bin/bash
# ==========================================
# Master Setup System & Environment - AJI STORE
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

# Variabel Repositori
REPO="raw.githubusercontent.com/arturrohim16-cloud/Script1/main"

# 1. Persiapan Awal
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      PREPARING SYSTEM & ENVIRONMENT            ${NC}"
echo -e "${GREEN}          BY AJI STORE PREMIUM                  ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
sleep 2

# 2. Update System & Install Core Packages
echo -e "${ORANGE}[1] Updating system and installing core packages...${NC}"
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt install -y jq curl wget sed git zip unzip build-essential net-tools socat chrony
apt install -y libnss3-dev libnspr4-dev pkg-config libpam0g-dev libcap-ng-dev libcap-ng-utils libselinux1-dev libcurl4-nss-dev flex bison make libnss3-tools libevent-dev

# 3. Instalasi Python & Pip (Lengkap)
echo -e "${ORANGE}[2] Installing Python 3 and pip environment...${NC}"
apt install -y python3 python3-pip python3-setuptools
# Beberapa script websocket butuh library khusus
pip3 install wheel
pip3 install pycryptodome

# 4. Sinkronisasi Waktu & Zone
echo -e "${ORANGE}[3] Synchronizing timezone to Jakarta...${NC}"
timedatectl set-timezone Asia/Jakarta

# 5. Membuat Struktur Folder Sistem
mkdir -p /etc/xray
mkdir -p /etc/v2ray
mkdir -p /usr/bin/xray
mkdir -p /var/lib/aji-store
mkdir -p /var/log/xray

# 6. Menjalankan Script Instalasi Protokol (SSH, Xray, dkk)
# Ini adalah bagian yang memanggil script yang kita buat di nomor 1-4
echo -e "${ORANGE}[4] Executing protocol installation scripts...${NC}"

wget -qO ssh-vpn.sh "https://${REPO}/ssh-vpn.sh" && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
wget -qO ins-xray.sh "https://${REPO}/ins-xray.sh" && chmod +x ins-xray.sh && ./ins-xray.sh
wget -qO set-br.sh "https://${REPO}/set-br.sh" && chmod +x set-br.sh && ./set-br.sh

# 7. DOWNLOAD MENU MANAGEMENT (TAHAP FINISHING)
# Inilah bagian yang si Bos maksud, mendownload file add-ssh, add-vmess, dll.
echo -e "${ORANGE}[5] Downloading Menu Management (Finishing)...${NC}"
cd /usr/bin

# Menu Utama
wget -O menu "https://${REPO}/menu.sh"
# Menu SSH & OVPN
wget -O add-ssh "https://${REPO}/add-ssh.sh"
wget -O del-ssh "https://${REPO}/del-ssh.sh"
wget -O renew-ssh "https://${REPO}/renew-ssh.sh"
wget -O cek-ssh "https://${REPO}/cek-ssh.sh"
# Menu Xray (Vmess, Vless, Trojan)
wget -O add-vmess "https://${REPO}/add-vmess.sh"
wget -O del-vmess "https://${REPO}/del-vmess.sh"
wget -O add-vless "https://${REPO}/add-vless.sh"
wget -O del-vless "https://${REPO}/del-vless.sh"
wget -O add-tru "https://${REPO}/add-tru.sh"
wget -O del-tru "https://${REPO}/del-tru.sh"
# Menu Tambahan
wget -O cert-xray "https://${REPO}/cert-xray.sh"
wget -O speedtest "https://${REPO}/speedtest_worker.py"
wget -O info "https://${REPO}/info.sh"
wget -O about "https://${REPO}/about.sh"

# Memberikan Izin Eksekusi ke Semua Menu
chmod +x menu add-ssh del-ssh renew-ssh cek-ssh add-vmess del-vmess add-vless del-vless add-tru del-tru cert-xray speedtest info about

# 8. Finalisasi
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}    SYSTEM SETUP & FINISHING COMPLETED!         ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}  Ketik 'menu' untuk melihat daftar perintah.    ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Membersihkan file installer sementara
cd /root
rm -f ssh-vpn.sh ins-xray.sh set-br.sh setup.sh

