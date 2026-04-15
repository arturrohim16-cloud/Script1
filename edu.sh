#!/bin/bash
# Proxy Service Installer for AJI SYSTEM
# Optimized for Ubuntu 20.04, 22.04 & 24.04

# 1. Service untuk WebSocket Non-TLS (Port 8880 / 80)
# Download Script Proxy dari GitHub
wget -q -O /usr/local/bin/ws-nontls https://raw.githubusercontent.com/arturrohim16-cloud/Script1/refs/heads/main/ws-nontls

# Memberi Izin Eksekusi agar script bisa berjalan
chmod +x /usr/local/bin/ws-nontls

cat > /etc/systemd/system/ws-nontls.service << END
[Unit]
Description=Python Proxy Non-TLS AJI SYSTEM
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
# Menggunakan python3 dan tanpa flag -O agar lebih stabil
ExecStart=/usr/bin/python3 /usr/local/bin/ws-nontls 8880
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

# Download Script Proxy OpenVPN dari GitHub
wget -q -O /usr/local/bin/ws-ovpn https://raw.githubusercontent.com/arturrohim16-cloud/Script1/refs/heads/main/ws-ovpn.py

# Memberi Izin Eksekusi agar script bisa berjalan
chmod +x /usr/local/bin/ws-ovpn

cat > /etc/systemd/system/ws-ovpn.service << END
[Unit]
Description=Python Proxy OpenVPN AJI SYSTEM
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 /usr/local/bin/ws-ovpn 2086
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

# 3. Service untuk WebSocket TLS/SSL (Port 443 / Port Lain)
cat > /etc/systemd/system/ws-tls.service << END
[Unit]
Description=Python Proxy TLS AJI SYSTEM
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 /usr/local/bin/ws-tls 443
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

# --- EKSEKUSI PERUBAHAN ---
echo "Memproses ulang semua service..."
systemctl daemon-reload

# Enable agar otomatis jalan saat VPS reboot
systemctl enable ws-nontls
systemctl enable ws-ovpn
systemctl enable ws-tls

# Restart untuk menerapkan kode Python 3 yang baru
systemctl restart ws-nontls
systemctl restart ws-ovpn
systemctl restart ws-tls

echo "Semua service Proxy AJI SYSTEM telah diperbarui dan dijalankan!"
