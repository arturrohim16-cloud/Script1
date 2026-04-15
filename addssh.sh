#!/bin/bash

# --- WARNA ---
NC='\e[0m'
GREEN='\e[0;32m'
CYAN='\e[0;36m'
YELLOW='\e[0;33m'
RED='\e[0;31m'
L_PURPLE='\e[1;35m'

# --- DATA VPS ---
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "$(curl -s ifconfig.me)")
IP=$(curl -s ifconfig.me)

clear
echo -e "${L_PURPLE}---------------------------------------${NC}"
echo -e "      CREATE PREMIUM SSH ACCOUNT       "
echo -e "${L_PURPLE}---------------------------------------${NC}"

# Input User
read -p "   Username : " user
if grep -w "^$user" /etc/passwd >/dev/null; then
    echo -e "   ${RED}Error: Username [$user] sudah ada!${NC}"
    exit 1
fi

read -p "   Password : " pass
read -p "   Expired  : " masa_aktif

# Animasi Loading
echo -e -n "   ${YELLOW}Processing...${NC} "
for ((i=0; i<10; i++)); do
    echo -ne "${CYAN}■${NC}"
    sleep 0.2
done
echo -e " ${GREEN}Done!${NC}"

# Logika Tanggal
exp=$(date -d "$masa_aktif days" +"%Y-%m-%d")
tgl=$(date -d "$masa_aktif days" +"%d %b %Y")

# Eksekusi Pembuatan User
useradd -e $exp -M -s /bin/false $user
echo "$user:$pass" | chpasswd
echo "### $user $exp" >> /etc/ssh-vpn/users

# --- PAYLOAD GENERATOR ---
# Sesuaikan port bug jika diperlukan (biasanya 80 untuk WS atau 443 untuk TLS)
PAYLOAD_WS="GET / HTTP/1.1[crlf]Host: ${DOMAIN}[crlf]Upgrade: websocket[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf][crlf]"

clear
echo -e "${L_PURPLE}---------------------------------------${NC}"
echo -e "      SSH ACCOUNT INFORMATION         "
echo -e "${L_PURPLE}---------------------------------------${NC}"
echo -e "   Username   : $user"
echo -e "   Password   : $pass"
echo -e "   Expired    : $tgl"
echo -e "   Host/IP    : $DOMAIN"
echo -e "   Port Open  : 22, 443, 80, 8080"
echo -e "${L_PURPLE}---------------------------------------${NC}"
echo -e "   ${CYAN}PAYLOAD HTTP WEBSOCKET:${NC}"
echo -e "   ${YELLOW}$PAYLOAD_WS${NC}"
echo -e "${L_PURPLE}---------------------------------------${NC}"
echo -e "   ${CYAN}SSH TLS / SSL:${NC}"
echo -e "   $user:$pass@$DOMAIN:443"
echo -e "${L_PURPLE}---------------------------------------${NC}"
echo -e "   ${CYAN}SSH HTTP CUSTOM:${NC}"
echo -e "   $IP:80@$user:$pass"
echo -e "${L_PURPLE}---------------------------------------${NC}"
echo -e "         AJI STORE PREMIUM             "
echo -e "${L_PURPLE}---------------------------------------${NC}"
