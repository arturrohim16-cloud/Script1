#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'

# 1. Cek apakah file domain sudah ada
if [ -f "/etc/xray/domain" ]; then
    SUB_DOMAIN=$(cat /etc/xray/domain)
    echo -e "${green}Menggunakan domain yang tersimpan: $SUB_DOMAIN${NC}"
else
    echo -e "${red}Error: File /etc/xray/domain tidak ditemukan!${NC}"
    exit 1
fi

# 2. Ambil NS_DOMAIN jika ada, jika tidak ada buat baru berdasarkan SUB_DOMAIN
if [ -f "/root/nsdomain" ]; then
    NS_DOMAIN=$(cat /root/nsdomain)
else
    NS_DOMAIN="ns-${SUB_DOMAIN}"
fi

# Konfigurasi Cloudflare
DOMAIN="mantapxsl.my.id"
CF_ID="slinfinity69@gmail.com"
CF_KEY="dd2c5e0313f122b3c1833471d469b1025f492"

set -euo pipefail
IP=$(wget -qO- icanhazip.com);

# Pastikan direktori ada
mkdir -p /usr/bin/xray
mkdir -p /usr/bin/v2ray
mkdir -p /etc/xray
mkdir -p /etc/v2ray
mkdir -p /var/lib/crot/

echo "Updating DNS for ${SUB_DOMAIN}..."
ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

# Update atau Buat A Record
RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

if [[ "${#RECORD}" -le 10 ]]; then
     RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)
else
     curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}'
fi

echo "Updating DNS NS for ${NS_DOMAIN}..."
NS_RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${NS_DOMAIN}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

if [[ "${#NS_RECORD}" -le 10 ]]; then
     curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${SUB_DOMAIN}'","ttl":120,"proxied":false}'
else
     curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${NS_RECORD}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${SUB_DOMAIN}'","ttl":120,"proxied":false}'
fi

# Simpan ulang konfigurasi agar sinkron
echo "IP=$SUB_DOMAIN" > /var/lib/crot/ipvps.conf
echo "$SUB_DOMAIN" > /root/domain
echo "$SUB_DOMAIN" > /etc/xray/domain
echo "$SUB_DOMAIN" > /etc/v2ray/domain
echo "$NS_DOMAIN" > /root/nsdomain

echo -e "--- Done ---"
echo "Host : $SUB_DOMAIN"
echo "Host SlowDNS : $NS_DOMAIN"

