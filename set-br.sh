#!/bin/bash
# ==========================================
# Script Backup & Restore VVIP - AJI STORE
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

echo -e "${CYAN}Memulai Instalasi Sistem Backup & Restore...${NC}"

# 1. Update dan Install Rclone (Mesin Backup)
apt install rclone -y
printf "q\n" | rclone config

# 2. Membuat Direktori Backup di Sistem
mkdir -p /root/backup
mkdir -p /etc/aji-store

# 3. Membuat Script Auto-Backup (backup.sh)
# Script ini akan mengumpulkan semua data user SSH, Xray, dan V2ray
cat > /usr/bin/backup << END
#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
IP=\$(wget -qO- ipinfo.io/ip);
date=\$(date +"%Y-%m-%d")

echo -e "\${GREEN}Memulai Proses Backup Data VPS...\${NC}"

# Membuat Folder Sementara
mkdir -p /root/backup-data
cp /etc/passwd /root/backup-data/
cp /etc/group /root/backup-data/
cp /etc/shadow /root/backup-data/
cp /etc/gshadow /root/backup-data/
cp -r /etc/xray /root/backup-data/
cp -r /etc/v2ray /root/backup-data/ 2>/dev/null
cp -r /home/vps/public_html /root/backup-data/ 2>/dev/null
cp /etc/shadowsocks-libev/config.json /root/backup-data/ss.json 2>/dev/null

# Membungkus Data menjadi ZIP
cd /root
zip -r backup-\$IP-\$date.zip backup-data
rm -rf /root/backup-data

# Mengirim ke Rclone (Jika sudah dikonfigurasi)
# rclone copy /root/backup-\$IP-\$date.zip remote:AJI-BACKUP

echo -e "\${GREEN}Backup Selesai! File tersimpan di /root/backup-\$IP-\$date.zip\${NC}"
END
chmod +x /usr/bin/backup

# 4. Membuat Script Restore (restore.sh)
# Untuk mengembalikan data jika pindah VPS
cat > /usr/bin/restore << END
#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

echo -e "\${GREEN}Memulai Proses Restore Data...\${NC}"
echo "Pastikan file backup .zip ada di folder /root/"
read -p "Masukkan Nama File Backup (contoh: backup-xxx.zip): " file

if [ -f "/root/\$file" ]; then
    unzip \$file
    cp backup-data/passwd /etc/
    cp backup-data/group /etc/
    cp backup-data/shadow /etc/
    cp backup-data/gshadow /etc/
    cp -r backup-data/xray /etc/
    rm -rf backup-data
    systemctl restart xray
    echo -e "\${GREEN}Restore Data Berhasil! SIlakan cek akun user Anda.\${NC}"
else
    echo -e "\${RED}File Tidak Ditemukan!\${NC}"
fi
END
chmod +x /usr/bin/restore

# 5. Membuat Script Ganti Password Backup (limitsmtp.sh / strt.sh)
# Opsional: Untuk keamanan tambahan
cat > /usr/bin/limitsmtp << END
#!/bin/bash
# Script untuk membatasi pengiriman email massal (Anti-SPAM)
iptables -A OUTPUT -p tcp --dport 25 -j DROP
iptables -A OUTPUT -p tcp --dport 465 -j DROP
iptables -A OUTPUT -p tcp --dport 587 -j DROP
iptables-save > /etc/iptables.up.rules
END
chmod +x /usr/bin/limitsmtp

# Jalankan limit SMTP secara otomatis
/usr/bin/limitsmtp

echo -e "${GREEN}Instalasi Backup & Restore Selesai!${NC}"
echo -e "${ORANGE}Gunakan perintah 'backup' untuk mulai mencadangkan data.${NC}"
echo -e "${ORANGE}Gunakan perintah 'restore' untuk mengembalikan data.${NC}"

