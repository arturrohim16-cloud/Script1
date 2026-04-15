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

systemctl daemon-reload
systemctl enable ws-python
systemctl start ws-python
