#!/bin/bash
# ==========================================
# Script Network Optimizer & Speed Booster
# Admin: AJI STORE PREMIUM
# ==========================================

# Warna Output Full
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
ORANGE='\033[0;33m'

echo -e "${CYAN}Memulai Optimasi Jaringan Tingkat Tinggi...${NC}"

# 1. Menghapus Limit Default Linux
# Kita naikkan batas file terbuka agar user banyak tidak lag
echo -e "${ORANGE}Meningkatkan Limit File Descriptor...${NC}"
cat > /etc/security/limits.conf << END
* soft nofile 65535
* hard nofile 65535
root soft nofile 65535
root hard nofile 65535
END

# 2. Tuning Kernel Sysctl (Bagian Paling Inti)
# Ini adalah settingan "Galak" untuk TCP Fast Open dan Buffer
echo -e "${ORANGE}Menerapkan TCP Tuning High-Performance...${NC}"
cat > /etc/sysctl.conf << END
# Optimasi Buffer Jaringan
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 50000
net.core.somaxconn = 10000

# Optimasi TCP Memory
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_mem = 786432 1048576 1572864

# Mengaktifkan TCP Fast Open (Sangat penting untuk tunneling)
net.ipv4.tcp_fastopen = 3

# Mengaktifkan BBRv3 / BBR Standard
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Proteksi dan Speed
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_nometrics_save = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_mtu_probing = 1
END

# 3. Menerapkan Perubahan Tanpa Reboot
sysctl -p

# 4. Verifikasi BBR Aktif
check_bbr=$(lsmod | grep bbr)
if [[ $check_bbr == *"tcp_bbr"* ]]; then
    echo -e "${GREEN}BBR Berhasil Diaktifkan dan Dioptimasi!${NC}"
else
    echo -e "${RED}Gagal mengaktifkan BBR. Pastikan Kernel Anda mendukung.${NC}"
fi

echo -e "${CYAN}Optimasi Selesai! Rasakan perbedaan kecepatannya.${NC}"
