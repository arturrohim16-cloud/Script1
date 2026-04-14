#!/bin/bash
# ==========================================
# Script Shadowsocks-libev + OBFS - AJI STORE
# ==========================================

# Warna Output Full (Sesuai Standar Mewah)
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

# Mengambil Data Internal VPS
MYIP=$(wget -qO- ipinfo.io/ip);
domain=$(cat /etc/xray/domain)

echo -e "${CYAN}Memulai Instalasi Shadowsocks-libev & Simple-OBFS...${NC}"

# 1. Update & Install Seluruh Dependensi System (Full)
apt-get update
apt-get install -y --no-install-recommends gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libev-dev libc-ares-dev libmbedtls-dev libsodium-dev libssl-dev pkg-config

# 2. Install Shadowsocks-libev Langsung dari Source/Repository
apt-get install -y shadowsocks-libev

# 3. Install Simple-OBFS (Alat Penyamaran Bug/Payload)
apt-get install -y simple-obfs

# 4. Membuat Konfigurasi Utama Shadowsocks (TLS) - Port 2443-2543
cat > /etc/shadowsocks-libev/config.json << END
{
    "server":"0.0.0.0",
    "server_port":2443,
    "local_port":1080,
    "password":"ajistorepremium",
    "timeout":300,
    "method":"aes-256-gcm",
    "mode":"tcp_and_udp",
    "fast_open":true,
    "plugin":"obfs-server",
    "plugin_opts":"obfs=tls;obfs-host=$domain"
}
END

# 5. Membuat Konfigurasi Shadowsocks (HTTP) - Port 3443-3543
cat > /etc/shadowsocks-libev/http.json << END
{
    "server":"0.0.0.0",
    "server_port":3443,
    "local_port":1080,
    "password":"ajistorepremium",
    "timeout":300,
    "method":"aes-256-gcm",
    "mode":"tcp_and_udp",
    "fast_open":true,
    "plugin":"obfs-server",
    "plugin_opts":"obfs=http;obfs-host=$domain"
}
END

# 6. Membuat Service Systemd untuk Shadowsocks TLS
cat > /etc/systemd/system/ss-tls.service << END
[Unit]
Description=Shadowsocks-libev TLS Server
After=network.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
ExecStartPre=/usr/bin/sleep 2
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/config.json
Restart=always

[Install]
WantedBy=multi-user.target
END

# 7. Membuat Service Systemd untuk Shadowsocks HTTP
cat > /etc/systemd/system/ss-http.service << END
[Unit]
Description=Shadowsocks-libev HTTP Server
After=network.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
ExecStartPre=/usr/bin/sleep 2
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/http.json
Restart=always

[Install]
WantedBy=multi-user.target
END

# 8. Pengaturan IPTables Firewall (Membuka Jalur Port Lengkap)
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2443:2543 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2443:2543 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 3443:3543 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 3443:3543 -j ACCEPT
iptables-save > /etc/iptables.up.rules

# 9. Mengaktifkan dan Menjalankan Seluruh Service
systemctl daemon-reload
systemctl enable ss-tls
systemctl start ss-tls
systemctl enable ss-http
systemctl start ss-http

echo -e "${GREEN}Instalasi Shadowsocks-libev + OBFS Selesai!${NC}"
echo -e "${ORANGE}Port TLS: 2443-2543${NC}"
echo -e "${ORANGE}Port HTTP: 3443-3543${NC}"
