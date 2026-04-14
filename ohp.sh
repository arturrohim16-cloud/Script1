#!/bin/bash
# ==========================================
# Script Over-HTTP-Puncher (OHP) VVIP - AJI STORE
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

echo -e "${CYAN}Memulai Instalasi OHP Server (SSH, Dropbear, OpenVPN)...${NC}"

# 1. Download Binary OHP (Mesin Utama)
# Kita letakkan di /usr/bin agar bisa dipanggil sistem kapan saja
wget -O /usr/bin/ohp "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/ohp/ohp"
chmod +x /usr/bin/ohp

# 2. Membuat Service untuk OHP - SSH (Port 8181)
# Menghubungkan port 8181 ke OpenSSH port 22
cat > /etc/systemd/system/ohp-ssh.service << END
[Unit]
Description=OHP Service For SSH
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/ohp -port 8181 -proxy 127.0.0.1:3128 -dest 127.0.0.1:22
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
END

# 3. Membuat Service untuk OHP - Dropbear (Port 8282)
# Menghubungkan port 8282 ke Dropbear port 109
cat > /etc/systemd/system/ohp-db.service << END
[Unit]
Description=OHP Service For Dropbear
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/ohp -port 8282 -proxy 127.0.0.1:3128 -dest 127.0.0.1:109
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
END

# 4. Membuat Service untuk OHP - OpenVPN (Port 8383)
# Menghubungkan port 8383 ke OpenVPN port 1194
cat > /etc/systemd/system/ohp-ovpn.service << END
[Unit]
Description=OHP Service For OpenVPN
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/ohp -port 8383 -proxy 127.0.0.1:3128 -dest 127.0.0.1:1194
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
END

# 5. Mengaktifkan dan Menjalankan Seluruh Service OHP
systemctl daemon-reload

echo -e "${ORANGE}Menjalankan OHP SSH...${NC}"
systemctl enable ohp-ssh
systemctl start ohp-ssh

echo -e "${ORANGE}Menjalankan OHP Dropbear...${NC}"
systemctl enable ohp-db
systemctl start ohp-db

echo -e "${ORANGE}Menjalankan OHP OpenVPN...${NC}"
systemctl enable ohp-ovpn
systemctl start ohp-ovpn

# 6. Pengaturan Firewall (Membuka Port OHP)
iptables -I INPUT -p tcp --dport 8181 -j ACCEPT
iptables -I INPUT -p tcp --dport 8282 -j ACCEPT
iptables -I INPUT -p tcp --dport 8383 -j ACCEPT
iptables-save > /etc/iptables.up.rules

echo -e "${GREEN}Instalasi OHP Selesai!${NC}"
echo -e "${PURPLE}OHP SSH      : 8181${NC}"
echo -e "${PURPLE}OHP Dropbear : 8282${NC}"
echo -e "${PURPLE}OHP OpenVPN  : 8383${NC}"

