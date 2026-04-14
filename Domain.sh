#!/bin/bash
# Script Pengatur Domain & SSL - AJI STORE
# =========================================

# Warna
red='\e[1;31m'
green='\e[1;32m'
NC='\e[0m'

# 1. Update & Install Tools yang dibutuhkan
apt update -y
apt install curl socat xz-utils wget apt-transport-https ssl-cert -y

# 2. Input Domain
clear
echo -e "${green}=========================================${NC}"
echo -e "       PENGATURAN DOMAIN & SSL"
echo -e "${green}=========================================${NC}"
read -rp "Masukkan Domain Anda: " domain
if [[ -z $domain ]]; then
    echo -e "${red}Error: Domain tidak boleh kosong!${NC}"
    exit 1
fi

# Simpan domain ke /root/domain untuk referensi script lain
echo "$domain" > /root/domain
echo "$domain" > /etc/xray/domain

# 3. Berhenti Nginx sebentar untuk proses SSL
systemctl stop nginx

# 4. Install ACME.sh
echo -e "${green}Memulai instalasi Sertifikat SSL...${NC}"
rm -rf /root/.acme.sh
curl https://get.acme.sh | sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server zerossl

# 5. Generate Sertifikat SSL
# Memastikan folder penyimpanan ada
mkdir -p /etc/xray
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# 6. Beri Izin Akses Sertifikat
chmod 644 /etc/xray/xray.crt
chmod 644 /etc/xray/xray.key

# 7. Jalankan Kembali Nginx
systemctl start nginx

echo -e "${green}=========================================${NC}"
echo -e " DOMAIN: $domain"
echo -e " SSL STATUS: BERHASIL DIPASANG"
echo -e "${green}=========================================${NC}"
sleep 2

