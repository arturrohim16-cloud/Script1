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

# --- LOGIKA DATA ---
CLIENT_NAME=$(cat /etc/xray/username 2>/dev/null || echo "Aji")
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Belum Terpasang")
RAM_TOTAL=$(free -m | awk 'NR==2{print $2}')
RAM_USED=$(free -m | awk 'NR==2{print $3}')
UPTIME=$(uptime -p | sed 's/up //g')
IP_VPS=$(curl -s ifconfig.me)
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 | head -n1)
OS_VER=$(lsb_release -ds)

# Kuota (vnstat)
IFACE=$(ip -o -4 route show to default | awk '{print $5}')
TODAY_USAGE=$(vnstat -i $IFACE --oneline | cut -d';' -f6 2>/dev/null || echo "0 MB")
MONTH_USAGE=$(vnstat -i $IFACE --oneline | cut -d';' -f11 2>/dev/null || echo "0 MB")

function check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "${GREEN}ON${NC}"
    else
        echo -e "${RED}OFF${NC}"
    fi
}

TOTAL_SSH=$(grep -c -E "^### " "/etc/ssh-vpn/users" 2>/dev/null || echo "0")
TOTAL_XRAY=$(grep -c -E "^### " "/etc/xray/config.json" 2>/dev/null || echo "0")

clear

# --- DASHBOARD (Gunakan echo -e di setiap baris) ---
echo -e "${L_CYAN}  .-------------------------------------------------------.${NC}"
echo -e "${L_PURPLE}  .::.            AJI STORE TUNNELING            .::.  ${NC}"
echo -e "${L_CYAN}  '-------------------------------------------------------'${NC}"
printf "  ${L_CYAN}%-10s :${NC} ${RED}%-15s${NC} ${L_CYAN}%-8s :${NC} ${GREEN}%-15s${NC}\n" "CLIENTS" "$CLIENT_NAME" "OS" "$OS_VER"
printf "  ${L_CYAN}%-10s :${NC} ${GREEN}%-15s${NC} ${L_CYAN}%-8s :${NC} ${GREEN}%-15s${NC}\n" "RAM" "$RAM_USED / $RAM_TOTAL MB" "UPTIME" "$UPTIME"
printf "  ${L_CYAN}%-10s :${NC} ${GREEN}%-15s${NC} ${L_CYAN}%-8s :${NC} ${GREEN}%-15s${NC}\n" "IP" "$IP_VPS" "ISP" "$ISP"
printf "  ${L_CYAN}%-10s :${NC} ${RED}%-15s${NC} ${L_CYAN}%-8s :${NC} ${GREEN}%-15s${NC}\n" "EXPIRED" "Lifetime" "DOMAIN" "$DOMAIN"
printf "  ${L_CYAN}%-10s :${NC} ${GREEN}%-15s${NC} ${L_CYAN}%-8s :${NC} ${BG_RED} %-13s ${NC}\n" "TODAY" "$TODAY_USAGE" "MONTH" "$MONTH_USAGE"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"
echo -e "            ${L_CYAN}[ SERVICE STATUS - GOOD ]${NC}"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"
echo -e "  ${L_CYAN}SSH   :${NC} $(check_service ssh)   ${L_CYAN}XRAY  :${NC} $(check_service xray)   ${L_CYAN}NGINX :${NC} $(check_service nginx)"
echo -e "  ${L_CYAN}ACCOUNT :${NC} ${GREEN}$TOTAL_SSH${NC} Users     ${L_CYAN}ACCOUNT :${NC} ${GREEN}$TOTAL_XRAY${NC} Users"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"
echo -e "   ${L_CYAN}(1)${NC} SSH/OPENVPN            ${L_CYAN}(6)${NC} ADMIN MENU"
echo -e "   ${L_CYAN}(2)${NC} XRAY MANAGER           ${L_CYAN}(7)${NC} BOT TELEGRAM"
echo -e "   ${L_CYAN}(3)${NC} ADD BUG CONFIG         ${L_CYAN}(8)${NC} UPDATE SCRIPT"
echo -e "   ${L_CYAN}(4)${NC} CHANGE WARNA           ${L_CYAN}(9)${NC} BACKUP & RESTORE"
echo -e "   ${L_CYAN}(5)${NC} REGISTER IP           ${L_CYAN}(10)${NC} FEATURES"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"
echo -e "   ${RED}[R] REBOOT SYSTEM${NC}                ${RED}[X] EXIT${NC}"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"
echo -e "      ${YELLOW}Keberanian diuji saat melawan keraguan.${NC}"
echo -e "${L_PURPLE}  ---------------------------------------------------------${NC}"
echo -n -e "  Select From option [1-10 or x] : "
case $opt in
    1) addssh ;;
    2) xray-menu ;;
    3) add-bug ;;
    4) change-color ;;
    5) reg-ip ;;
    6) admin-menu ;;
    7) bot-tele ;;
    8) update-script ;;
    9) backup-menu ;;
    10) features ;;
    [rR]) reboot ;;
    [xX]) exit 0 ;;
    *) echo "Pilihan tidak ada!" && sleep 1 && menu ;;
esac
