#!/bin/bash
# ==========================================
# Script Auto Pointing Domain - AJI STORE
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

# Menyiapkan variabel sistem
MYIP=$(wget -qO- ipinfo.io/ip);
rm -f /etc/xray/domain
mkdir -p /etc/xray

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
echo -e "          SETTING DOMAIN CLOUDFLARE             \n"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Input Data Cloudflare (Wajib diisi oleh user saat menjalankan)
echo -e "${ORANGE}Silakan Masukkan Data Cloudflare Anda:${NC}"
read -p "   Masukkan Domain Utama (Contoh: ajistore.com): " DOMAIN
read -p "   Masukkan Subdomain (Contoh: vps1): " SUB
read -p "   Masukkan Email Cloudflare: " EMAIL
read -p "   Masukkan API Key Cloudflare (Global API): " KEY

# Menggabungkan Subdomain dan Domain
SUB_DOMAIN="${SUB}.${DOMAIN}"
echo -e "\n${CYAN}Sedang Menghubungkan ${SUB_DOMAIN} ke IP ${MYIP}...${NC}"

# 1. Mencari Zone ID Domain
ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
     -H "X-Auth-Email: ${EMAIL}" \
     -H "X-Auth-Key: ${KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

if [[ $ZONE == "" || $ZONE == "null" ]]; then
    echo -e "${RED}Gagal! Domain tidak ditemukan di akun Cloudflare Anda.${NC}"
    exit 1
fi

# 2. Mencari Record ID (Jika subdomain sudah ada sebelumnya)
RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
     -H "X-Auth-Email: ${EMAIL}" \
     -H "X-Auth-Key: ${KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

# 3. Proses Update atau Create Record DNS
if [[ "${#RECORD}" -le 10 ]]; then
     # Jika belum ada, buat record baru
     RESULT=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
          -H "X-Auth-Email: ${EMAIL}" \
          -H "X-Auth-Key: ${KEY}" \
          -H "Content-Type: application/json" \
          --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${MYIP}'","ttl":120,"proxied":false}')
     echo -e "${GREEN}Berhasil membuat Subdomain baru!${NC}"
else
     # Jika sudah ada, update IP-nya
     RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
          -H "X-Auth-Email: ${EMAIL}" \
          -H "X-Auth-Key: ${KEY}" \
          -H "Content-Type: application/json" \
          --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${MYIP}'","ttl":120,"proxied":false}')
     echo -e "${GREEN}Berhasil memperbarui Subdomain yang sudah ada!${NC}"
fi

# 4. Menyimpan Domain ke dalam Sistem VPS
echo "${SUB_DOMAIN}" > /etc/xray/domain
echo "${SUB_DOMAIN}" > /root/domain

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN} Domain Anda Sekarang : ${SUB_DOMAIN}${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Membersihkan temporary file
rm -f /root/slhost.sh

