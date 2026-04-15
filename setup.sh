#!/bin/bash
# ==========================================
# Auto Installer Script AJI STORE PREMIUM
# ==========================================

# Warna
NC='\e[0m'
GREEN='\e[0;32m'
RED='\e[0;31m'
CYAN='\e[0;36m'
YELLOW='\e[0;33m'

# 1. PEMBERSIHAN VPS (WIPEOUT)
echo -e "${CYAN}Cleaning up old installations...${NC}"
systemctl stop ws-python 2>/dev/null
systemctl stop ws-stunnel 2>/dev/null
rm -f /usr/bin/menu
rm -f /usr/bin/addssh
rm -f /usr/local/bin/ws-python
rm -f /usr/local/bin/ws-stunnel
rm -f /etc/systemd/system/ws-python.service
rm -f /etc/systemd/system/ws-stunnel.service

# 2. UPDATE SYSTEM & INSTALL DEPENDENCIES
echo -e "${CYAN}Updating system and installing dependencies...${NC}"
apt update -y
apt upgrade -y
apt install -y python3 python3-pip curl wget lsb-release vnstat jq sed awk

# Pastikan vnstat aktif
systemctl enable vnstat
systemctl start vnstat

# 3. MEMBUAT DIREKTORI DATA
mkdir -p /etc/xray
mkdir -p /etc/ssh-vpn
touch /etc/ssh-vpn/users

# 4. DOWNLOAD SEMUA FILE SCRIPT
echo -e "${CYAN}Downloading scripts from GitHub...${NC}"
REPO="https://raw.githubusercontent.com/arturrohim16-cloud/Script1/refs/heads/main"

wget -O /usr/bin/menu "${REPO}/menu.sh"
wget -O /usr/bin/addssh "${REPO}/addssh.sh"
wget -O /usr/local/bin/ws-python "${REPO}/ws-python"
wget -O /usr/local/bin/ws-stunnel "${REPO}/ws-stunnel"

# Memberikan izin eksekusi
chmod +x /usr/bin/menu
chmod +x /usr/bin/addssh
chmod +x /usr/local/bin/ws-python
chmod +x /usr/local/bin/ws-stunnel

# 5. MEMBUAT SERVICE SYSTEMD (WS-PYTHON)
cat > /etc/systemd/system/ws-python.service <<EOF
[Unit]
Description=Python WebSocket HTTP Proxy
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/ws-python
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF

# 6. MEMBUAT SERVICE SYSTEMD (WS-STUNNEL)
cat > /etc/systemd/system/ws-stunnel.service <<EOF
[Unit]
Description=Python WebSocket TLS Proxy
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/ws-stunnel
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF

# 7. AKTIVASI SEMUA SERVICE
echo -e "${CYAN}Activating services...${NC}"
systemctl daemon-reload
systemctl enable ws-python
systemctl restart ws-python
systemctl enable ws-stunnel
systemctl restart ws-stunnel

# 8. FINISHING
clear
echo -e "${GREEN}===========================================${NC}"
echo -e "   INSTALLATION COMPLETED SUCCESSFULLY    "
echo -e "${GREEN}===========================================${NC}"
echo -e "   ${YELLOW}Commands:${NC}"
echo -e "   - menu   : Open Dashboard"
echo -e "   - addssh : Create SSH Account"
echo -e "${GREEN}===========================================${NC}"
echo -e "   VPS will reboot in 5 seconds..."
sleep 5
reboot

