#!/bin/bash
# ==========================================
# Script Add SSH & WS VVIP - AJI STORE
# ==========================================

# Warna Mewah
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'
NC='\e[0m'

# Fungsi Loading Animasi
loading_anim() {
    local -a chars=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" )
    local msg="$1"
    echo -ne "${cyan}$msg${NC} "
    for (( i=0; i<15; i++ )); do
        echo -ne "${magenta}${chars[$((i%10))]}${NC}"
        sleep 0.1
        echo -ne "\b"
    done
    echo -e "${green} DONE!${NC}"
}

# Ambil Data Server
MYIP=$(wget -qO- ipinfo.io/ip);
domain=$(cat /etc/xray/domain)

clear
echo -e "${cyan}╔════════════════════════════════════════════╗${NC}"
echo -e "${cyan}║${NC}        ${yellow}ADD SSH & WEBSOCKET VVIP${NC}          ${cyan}║${NC}"
echo -e "${cyan}╚════════════════════════════════════════════╝${NC}"

# Input Data
read -p "  Username : " user
if grep -qw "$user" /etc/passwd; then
    echo -e "${red}Error: Username [$user] sudah ada!${NC}"
    exit 1
fi

read -p "  Password : " pass
read -p "  Expired  : " masa_aktif

# Proses Pembuatan (Pake Animasi)
echo ""
loading_anim "Checking system database..."
loading_anim "Creating account in VPS..."
loading_anim "Generating payloads & config..."
echo ""

# Eksekusi Tambah User
exp=$(date -d "$masa_aktif days" +"%Y-%m-%d")
created=$(date +"%Y-%m-%d")
useradd -e $exp -M -s /bin/false $user
echo "$user:$pass" | chpasswd

# Output Mewah
clear
echo -e "${cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${magenta}         ACCOUNT SSH & WS PREMIUM${NC}"
echo -e "${cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${yellow} Domain      :${NC} $domain"
echo -e "${yellow} Username    :${NC} $user"
echo -e "${yellow} Password    :${NC} $pass"
echo -e "${yellow} Created     :${NC} $created"
echo -e "${yellow} Expired     :${NC} $exp"
echo -e "${cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${magenta} HOST / IP   :${NC} $MYIP"
echo -e "${magenta} Port TLS    :${NC} 443"
echo -e "${magenta} Port NTLS   :${NC} 80, 8080"
echo -e "${magenta} Port SSH    :${NC} 143, 109"
echo -e "${cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${green} PAYLOAD WEBSOCKET (TLS/NTLS)${NC}"
echo -e " GET /ssh-ws HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf]"
echo -e "${cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${yellow}  TERIMA KASIH TELAH MENGGUNAKAN AJI STORE${NC}"
echo -e "${cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

