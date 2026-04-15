#!/bin/bash
# ==========================================
# Script Install SSH & Stunnel AJI STORE
# ==========================================

# Warna untuk output
export NC='\e[0m'
export GREEN='\e[0;32m'
export RED='\e[0;31m'
export YELLOW='\e[0;33m'
export CYAN='\e[0;36m'

# Repo URL
REPO="https://raw.githubusercontent.com/arturrohim16-cloud/Script1/refs/heads/main"

echo -e "${CYAN}Starting Install SSH & Stunnel...${NC}"

apt update && apt upgrade -y
apt install -y dropbear stunnel4 openssl wget curl

mkdir -p /var/lib/tunnel
domain=$(cat /etc/xray/domain)

openssl req -new -x509 -days 3650 -nodes -out /var/lib/tunnel/server.crt -keyout /var/lib/tunnel/server.key -subj "/C=ID/ST=Jawa/L=Jakarta/O=AjiStore/CN=${domain}"

chmod 600 /var/lib/tunnel/server.key
chmod 644 /var/lib/tunnel/server.crt

apt -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 143"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells

cat > /etc/stunnel/stunnel.conf <<EOF
cert = /var/lib/tunnel/server.crt
key = /var/lib/tunnel/server.key
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 445
connect = 127.0.0.1:109

[openssh]
accept = 777
connect = 127.0.0.1:443

[openvpn]
accept = 990
connect = 127.0.0.1:1194
EOF

sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
# 4. Download Menu & Script Pendukung
echo -e "${YELLOW}Downloading Menu Scripts from Repo...${NC}"
wget -O /usr/bin/menu "${REPO}/menu.sh"
wget -O /usr/bin/addssh "${REPO}/addssh.sh"
wget -O /usr/bin/usernew "${REPO}/addssh.sh" # Alias untuk usernew
wget -O /usr/bin/edu "${REPO}/edu.sh"
wget -O /usr/bin/fix-domain "${REPO}/setup.sh" # Jika ingin fix domain terintegrasi

# Memberikan Izin Eksekusi
chmod +x /usr/bin/menu
chmod +x /usr/bin/addssh
chmod +x /usr/bin/usernew
chmod +x /usr/bin/edu

# 5. Restart Services
echo -e "${CYAN}Restarting Services...${NC}"
systemctl daemon-reload
systemctl restart dropbear
systemctl enable dropbear
systemctl restart stunnel4
systemctl enable stunnel4

echo -e "${GREEN}===========================================${NC}"
echo -e "   SSH & STUNNEL INSTALLATION COMPLETED   "
echo -e "${GREEN}===========================================${NC}"

