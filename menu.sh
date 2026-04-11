#!/bin/bash

# --- WARNA (ANSI CODE) ---
NC='\e[0m'
GREEN='\e[0;32m'
PURPLE='\e[0;35m'
CYAN='\e[0;36m'
RED='\e[0;31m'
YELLOW='\e[0;33m'
BG_RED='\e[41;37m'
L_PURPLE='\e[1;35m'
L_CYAN='\e[1;36m'

# --- LOGIKA OTOMATIS DATA VPS ---
# Mengambil Nama Client dari file lisensi (nanti kita buat sistem lisensinya)
CLIENT_NAME=$(cat /etc/xray/username 2>/dev/null || echo "Aji")

# RAM: Mengambil sisa penggunaan vs total
RAM_TOTAL=$(free -m | awk 'NR==2{print $2}')
RAM_USED=$(free -m | awk 'NR==2{print $3}')

# IP & ISP: Mengambil langsung dari internet
IP_VPS=$(curl -s ifconfig.me)
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)

# OS: Mengambil deskripsi Ubuntu
OS_VER=$(lsb_release -ds)

# Uptime: Mengambil waktu aktif server
UPTIME=$(uptime -p | sed 's/up //g')

# Domain: Mengambil dari konfigurasi Nginx/Xray yang ada
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Belum Terpasang")
# Update sistem dan install bahan-bahan pendukung
apt update -y && apt upgrade -y
apt install -y vnstat lsb-release curl socat grep sed awk

# Mengaktifkan vnstat untuk memantau trafik (kuota)
systemctl enable vnstat
systemctl start vnstat

# Membuat direktori tempat penyimpanan data script
mkdir -p /etc/xray
mkdir -p /etc/ssh-vpn

# --- INPUT DATA VPS ---
read -p "Masukkan Nama Owner/Client: " owner_name
read -p "Masukkan Domain VPS Anda: " vps_domain

# Menyimpan data input ke dalam sistem agar dibaca oleh dashboard
echo "$owner_name" > /etc/xray/username
echo "$vps_domain" > /etc/xray/domain

# Memberikan izin eksekusi pada script menu
chmod +x menu.sh

# Traffic Usage (Membutuhkan vnstat, jika belum ada akan menampilkan 0)
TODAY_USAGE=$(vnstat -i eth0 --oneline | cut -d';' -f6 2>/dev/null || echo "0 MB")
MONTH_USAGE=$(vnstat -i eth0 --oneline | cut -d';' -f11 2>/dev/null || echo "0 MB")

# Speed: (Tampilan statis/link speed)
SPEED=$(ethstatus -i eth0 2>/dev/null | grep "Current Speed" | awk '{print $3}' || echo "1.00 Gbps")

# Status Service (Mengecek apakah service running atau mati)
function check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "${GREEN}ON${NC}"
    else
        echo -e "${RED}OFF${NC}"
    fi
}

# Hitung Akun (Mengecek jumlah baris di config)
TOTAL_SSH=$(grep -c -E "^### " "/etc/ssh-vpn/users" 2>/dev/null || echo "0")
TOTAL_XRAY=$(grep -c -E "^### " "/etc/xray/config.json" 2>/dev/null || echo "0")

clear

# --- HEADER ATAS ---
echo -e "${L_CYAN}  .-------------------------------------------------------.${NC}"
echo -e "${L_PURPLE}  .::.            AJI STORE TUNNELING            .::.  ${NC}"
echo -e "${L_CYAN}  '-------------------------------------------------------'${NC}"

# --- INFO SISTEM ---
echo -e "  ${L_CYAN}CLIENTS :${NC} ${RED}$CLIENT_NAME${NC}             ${L_CYAN}OS     :${NC} ${GREEN}$OS_VER${NC}"
echo -e "  ${L_CYAN}RAM     :${NC} ${GREEN}$RAM_USED / $RAM_TOTAL MB${NC}      ${L_CYAN}UPTIME :${NC} ${GREEN}$UPTIME${NC}"
echo -e "  ${L_CYAN}IP      :${NC} ${GREEN}$IP_VPS${NC}     ${L_CYAN}ISP    :${NC} ${GREEN}$ISP${NC}"
echo -e "  ${L_CYAN}EXPIRED :${NC} ${RED}Lifetime${NC}            ${L_CYAN}DOMAIN :${NC} ${GREEN}$DOMAIN${NC}"
echo -e "  ${L_CYAN}RX      :${NC} ${GREEN}Online${NC}              ${L_CYAN}LAST   :${NC} ${GREEN}:${NC}"
echo -e "  ${L_CYAN}TX      :${NC} ${GREEN}Online${NC}              ${L_CYAN}TODAY  :${NC} ${GREEN}$TODAY_USAGE${NC}"
echo -e "  ${L_CYAN}SPEED   :${NC} ${GREEN}$SPEED${NC}          ${L_CYAN}MONTH  :${NC} ${BG_RED} $MONTH_USAGE ${NC}"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"

# --- SERVICE STATUS ---
echo -e "            ${L_CYAN}[ SERVICE STATUS - GOOD ]${NC}"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"
echo -e "  ${L_CYAN}PROXY   :${NC} $(check_service squid)     ${L_CYAN}SSH  :${NC} $(check_service ssh)     ${L_CYAN}ACCOUNT :${NC} ${GREEN}$TOTAL_SSH${NC}"
echo -e "  ${L_CYAN}NGINX   :${NC} $(check_service nginx)     ${L_CYAN}XRAY :${NC} $(check_service xray)     ${L_CYAN}ACCOUNT :${NC} ${GREEN}$TOTAL_XRAY${NC}"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"

# --- MENU UTAMA ---
echo -e "   ${L_CYAN}(1)${NC} SSH/OPENVPN            ${L_CYAN}(6)${NC} ADMIN MENU"
echo -e "   ${L_CYAN}(2)${NC} XRAY MANAGER           ${L_CYAN}(7)${NC} BOT TELEGRAM"
echo -e "   ${L_CYAN}(3)${NC} ADD BUG CONFIG         ${L_CYAN}(8)${NC} UPDATE SCRIPT"
echo -e "   ${L_CYAN}(4)${NC} CHANGE WARNA           ${L_CYAN}(9)${NC} BACKUP & RESTORE"
echo -e "   ${L_CYAN}(5)${NC} REGISTER IP           ${L_CYAN}(10)${NC} FEATURES"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"

# --- REBOOT & EXIT ---
echo -e "   ${RED}[ REBOOT SYSTEM ]${NC}                   ${RED}[ EXIT ]${NC}"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"

# --- QUOTES ---
echo -e "      ${YELLOW}Keberanian diuji saat melawan keraguan.${NC}"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"

echo -n -e "  Select From option [1/10 or x] : "
read opt

