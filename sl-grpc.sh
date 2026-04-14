#!/bin/bash
# ==========================================
# Script Xray GRPC Premium - Support Random UUID
# Admin: AJI STORE
# ==========================================

# Warna Output Full
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

# Mengambil Data Domain
domain=$(cat /etc/xray/domain)

echo -e "${CYAN}Memulai Instalasi Xray GRPC (Support Multi-User & Random UUID)...${NC}"

# 1. Menyiapkan Folder dan Log
mkdir -p /etc/xray
mkdir -p /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log

# 2. Membuat Konfigurasi Xray GRPC - VMESS (Port 1180)
# Bagian "clients" dikosongkan agar bisa diisi oleh script add-ws.sh secara dinamis
cat > /etc/xray/vmess-grpc.json << END
{
    "log": {
        "access": "/var/log/xray/access.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 1180,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    #AkunMarker
                ]
            },
            "streamSettings": {
                "network": "grpc",
                "security": "tls",
                "tlsSettings": {
                    "certificates": [
                        {
                            "certificateFile": "/etc/xray/xray.crt",
                            "keyFile": "/etc/xray/xray.key"
                        }
                    ]
                },
                "grpcSettings": {
                    "serviceName": "vmess-grpc"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        }
    ]
}
END

# 3. Membuat Konfigurasi Xray GRPC - VLESS (Port 2280)
cat > /etc/xray/vless-grpc.json << END
{
    "log": {
        "access": "/var/log/xray/access.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 2280,
            "protocol": "vless",
            "settings": {
                "clients": [
                    #AkunMarker
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "grpc",
                "security": "tls",
                "tlsSettings": {
                    "certificates": [
                        {
                            "certificateFile": "/etc/xray/xray.crt",
                            "keyFile": "/etc/xray/xray.key"
                        }
                    ]
                },
                "grpcSettings": {
                    "serviceName": "vless-grpc"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        }
    ]
}
END

# 4. Membuat Service Systemd (Full Version)
cat > /etc/systemd/system/vmess-grpc.service << END
[Unit]
Description=Xray VMESS GRPC Service
After=network.target nss-lookup.target

[Service]
User=root
ExecStart=/usr/local/bin/xray run -c /etc/xray/vmess-grpc.json
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
END

cat > /etc/systemd/system/vless-grpc.service << END
[Unit]
Description=Xray VLESS GRPC Service
After=network.target nss-lookup.target

[Service]
User=root
ExecStart=/usr/local/bin/xray run -c /etc/xray/vless-grpc.json
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
END

# 5. Jalankan Service
systemctl daemon-reload
systemctl enable vmess-grpc
systemctl start vmess-grpc
systemctl enable vless-grpc
systemctl start vless-grpc

# 6. Firewall
iptables -I INPUT -p tcp --dport 1180 -j ACCEPT
iptables -I INPUT -p tcp --dport 2280 -j ACCEPT
iptables-save > /etc/iptables.up.rules

echo -e "${GREEN}Instalasi Xray GRPC Berhasil (Support Random UUID)!${NC}"

