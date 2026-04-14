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

# // Certificate File Path
path_crt="/etc/xray/xray.crt"
path_key="/etc/xray/xray.key"

# Buat Config Xray Lengkap
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
      "settings": {
        "clients": [
          {
            "id": "${uuid1}",
            "alterId": 0
#xray-vmess-tls
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "${path_crt}",
              "keyFile": "${path_key}"
            }
          ]
        },
        "wsSettings": {
          "path": "/vmess/",
          "headers": {
            "Host": ""
          }
        }
      }
    },
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid2}",
            "alterId": 0
#xray-vmess-nontls
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vmess/",
          "headers": {
            "Host": ""
          }
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    },
    {
      "port": 8443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid3}"
#xray-vless-tls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "${path_crt}",
              "keyFile": "${path_key}"
            }
          ]
        },
        "wsSettings": {
          "path": "/vless/",
          "headers": {
            "Host": ""
          }
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    },
    {
      "port": 80,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid4}"
#xray-vless-nontls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vless/",
          "headers": {
            "Host": ""
          }
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    },
    {
      "port": 2083,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${uuid5}"
#xray-trojan
          }
        ],
        "fallbacks": [
          {
            "dest": 80
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "${path_crt}",
              "keyFile": "${path_key}"
            }
          ],
          "alpn": ["http/1.1"]
        }
      }
     }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": ["0.0.0.0/8", "10.0.0.0/8", "127.0.0.1/32"],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": ["bittorrent"]
      }
    ]
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  }
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

