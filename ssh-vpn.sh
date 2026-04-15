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

# 1. Update & Install Base Package
apt update && apt upgrade -y
apt install -y dropbear stunnel4 openssl wget curl

# 2. Konfigurasi Dropbear
echo -e "${GREEN}Configuring Dropbear...${NC}"
cat > /etc/default/dropbear <<EOF
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 109 -p 447"
DROPBEAR_BANNER="/etc/issue.net"
DROPBEAR_RECEIVE_WINDOW=65536
EOF

# Membuat Banner Default
echo "AJI STORE PREMIUM" > /etc/issue.net

# 3. Konfigurasi Stunnel4
echo -e "${GREEN}Configuring Stunnel4...${NC}"
cat > /etc/stunnel/stunnel.conf <<EOF
pid = /var/run/stunnel4.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:143
EOF

# Membuat Sertifikat SSL Self-Signed
openssl req -new -x509 -days 365 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/C=ID/ST=Jawa/L=Jakarta/O=AjiStore/CN=aji.izz-store.my.id"

# Mengaktifkan Autostart Stunnel
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

