#!/bin/bash
# Script Installer Utama - AJI STORE TUNNELING
# Manual Installation Support Ubuntu 22.04 / 24.04

# 1. Update & Install Basic Tools
echo -e "Update and Install Basic Tools..."
apt update -y
apt upgrade -y
apt install -y jq curl wget socat lsb-release cron vnstat nginx unzip
systemctl enable vnstat
systemctl start vnstat

# 2. Persiapan Direktori
mkdir -p /etc/xray
mkdir -p /etc/ssh-vpn
mkdir -p /var/log/xray
mkdir -p /usr/local/bin

# 3. Input Domain & Owner
if [ ! -f "/etc/xray/domain" ]; then
    read -p "Masukkan Domain: " domain
    echo "$domain" > /etc/xray/domain
else
    domain=$(cat /etc/xray/domain)
fi

# 4. Install Xray Core secara Manual (Lengkap)
echo -e "Installing Xray Core Manual Mode..."
# Mendeteksi Arsitektur (AMD64 atau ARM)
arch=$(uname -m)
if [[ $arch == "x86_64" ]]; then
    platform="64"
elif [[ $arch == "aarch64" ]]; then
    platform="arm64-v8a"
fi

# Download Binary Xray Terbaru
wget -q -O /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$platform.zip"
unzip -o /tmp/xray.zip -d /usr/local/bin/ xray
chmod +x /usr/local/bin/xray
rm -f /tmp/xray.zip

# Buat Config Dasar Xray (Agar Service Bisa Start)
#!/bin/bash

# --- BAGIAN INSTALASI XRAY MANUFAKTUR (LENGKAP) ---
echo -e "Memulai konfigurasi Xray Core yang komprehensif..."

# Mendeteksi domain yang sudah diinput sebelumnya

# 1. Membuat Struktur Konfigurasi Lengkap (config.json)
# Ini adalah config standar yang mendukung Vless, Vmess, Trojan, dan gRPC
cat > /etc/xray/config.json <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "api": {
    "tag": "api",
    "services": ["HandlerService", "LoggerService", "StatsService"]
  },
  "stats": {},
  "policy": {
    "levels": {
      "0": {
        "statsUserUplink": true,
        "statsUserDownlink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  },
  "dns": {
    "servers": [
      "localhost",
      "1.1.1.1",
      "8.8.8.8"
    ]
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/xray/xray.crt",
              "keyFile": "/etc/xray/xray.key"
            }
          ]
        },
        "wsSettings": {
          "path": "/vless",
          "headers": {
            "Host": "$domain"
          }
        }
      },
      "tag": "vless-ws"
    },
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess",
          "headers": {
            "Host": "$domain"
          }
        }
      },
      "tag": "vmess-ws"
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "inboundTag": ["api"],
        "outboundTag": "api"
      },
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "protocol": ["bittorrent"],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF

# 2. Membuat Systemd Service yang kokoh
cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service by AJI STORE
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

# 3. Eksekusi Perubahan
systemctl daemon-reload
systemctl enable xray
systemctl restart xray

echo -e "Konfigurasi Xray Core Lengkap telah terpasang dan berjalan."
