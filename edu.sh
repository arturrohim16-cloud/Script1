# 1. Download script python dari github dan simpan di folder local bin
wget -O /usr/local/bin/ws-python "https://raw.githubusercontent.com/arturrohim16-cloud/Script1/refs/heads/main/ws-python"

# 2. Berikan izin eksekusi agar script bisa berjalan
chmod +x /usr/local/bin/ws-python

# 3. Buat file service agar auto-run (otomatis jalan saat VPS restart)
cat > /etc/systemd/system/ws-python.service <<EOF
[Unit]
Description=Python WebSocket Proxy Aji Store
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 /usr/local/bin/ws-python
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF

# 4. Refresh systemd, aktifkan, dan jalankan service-nya
systemctl daemon-reload
systemctl enable ws-python
systemctl restart ws-python

# 5. Cek status apakah sudah berjalan (Running)
systemctl status ws-python


# 1. Download script dari Github Anda
wget -O /usr/local/bin/ws-stunnel "https://raw.githubusercontent.com/arturrohim16-cloud/Script1/refs/heads/main/ws-stunnel"

# 2. Beri izin eksekusi
chmod +x /usr/local/bin/ws-stunnel

# 3. Buat file service Systemd
cat > /etc/systemd/system/ws-stunnel.service <<EOF
[Unit]
Description=Python WebSocket TLS Proxy Aji Store
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 /usr/local/bin/ws-stunnel
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF

# 4. Aktifkan dan Jalankan Service
systemctl daemon-reload
systemctl enable ws-stunnel
systemctl restart ws-stunnel

# 5. Cek Status
systemctl status ws-stunnel
