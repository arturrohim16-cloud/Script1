#!/bin/bash
# Script Installer Utama - AJI STORE TUNNELING
# Manual Installation Support Ubuntu 22.04 / 24.04

# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'

# 1. Update & Install Basic Tools
echo -e "${GREEN}Update and Install Basic Tools...${NC}"
apt update -y
apt upgrade -y
apt install -y jq curl wget socat lsb-release cron vnstat nginx unzip iptables iptables-persistent dnsutils ntpdate chrony
systemctl enable vnstat
systemctl start vnstat

# 2. Persiapan Direktori
mkdir -p /etc/xray
mkdir -p /etc/ssh-vpn
mkdir -p /var/log/xray
mkdir -p /usr/local/bin
mkdir -p /var/log/trojan-go
mkdir -p /etc/trojan-go

# 3. PANGGIL SCRIPT DOMAIN (Integrasi Baru)
# Menjalankan domain.sh untuk setting Domain & SSL otomatis
echo -e "${BLUE}Menjalankan Konfigurasi Domain & SSL...${NC}"
wget -O domain.sh "https://raw.githubusercontent.com/arturrohim16-cloud/Script1/main/domain.sh"
chmod +x domain.sh
./domain.sh

# Ambil variabel domain yang sudah dibuat oleh domain.sh
domain=$(cat /root/domain)

# 4. Sinkronisasi Waktu
timedatectl set-timezone Asia/Jakarta
ntpdate pool.ntp.org
systemctl enable chrony && systemctl restart chrony

# 5. Install Xray Core
echo -e "${GREEN}Installing Xray Core...${NC}"
latest_version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
xraycore_link="https://github.com/XTLS/Xray-core/releases/download/v$latest_version/xray-linux-64.zip"

cd `mktemp -d`
curl -sL "$xraycore_link" -o xray.zip
unzip -q xray.zip && rm -rf xray.zip
mv xray /usr/local/bin/xray
chmod +x /usr/local/bin/xray

# 6. Generate UUID untuk Config
uuid1=$(cat /proc/sys/kernel/random/uuid)
uuid2=$(cat /proc/sys/kernel/random/uuid)
uuid3=$(cat /proc/sys/kernel/random/uuid)
uuid4=$(cat /proc/sys/kernel/random/uuid)
uuid5=$(cat /proc/sys/kernel/random/uuid)

# 7. Buat Config Xray
cat > /etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 8443,
      "protocol": "vmess",
      "settings": { "clients": [{ "id": "${uuid1}", "alterId": 0 }] },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": { "certificates": [{ "certificateFile": "/etc/xray/xray.crt", "keyFile": "/etc/xray/xray.key" }] },
        "wsSettings": { "path": "/vmess/" }
      }
    },
    {
      "port": 80,
      "protocol": "vless",
      "settings": { "clients": [{ "id": "${uuid4}" }], "decryption": "none" },
      "streamSettings": { "network": "ws", "security": "none", "wsSettings": { "path": "/vless/" } }
    }
  ],
  "outbounds": [{ "protocol": "freedom", "settings": {} }]
}
END

# 8. Install Xray Service
cat > /etc/systemd/system/xray.service << END
[Unit]
Description=Xray Service Mod By AJI
After=network.target nss-lookup.target

[Service]
User=root
ExecStart=/usr/local/bin/xray -config /etc/xray/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

# 9. Firewall & IPTables
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
netfilter-persistent save
netfilter-persistent reload

# 10. Start Services
systemctl daemon-reload
systemctl enable xray
systemctl restart xray
systemctl restart nginx

echo -e "${GREEN}Installation Berhasil Terhubung dengan Domain: $domain${NC}"

