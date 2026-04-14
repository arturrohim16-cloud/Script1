#!/bin/bash
# ==========================================
# Script SSTP VPN Premium - AJI STORE
# ==========================================

# Warna untuk output agar rapi
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

# Variabel Utama
MYIP=$(wget -qO- ipinfo.io/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NIC=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

echo -e "${CYAN}Memulai Instalasi SSTP VPN Server...${NC}"

# 1. Install Dependensi yang Dibutuhkan
apt update
apt-get install -y cmake libpcre3-dev libssl-dev libsqlite3-dev libreadline-dev

# 2. Download dan Compile Accel-PPP (Mesin Utama SSTP)
cd /usr/bin
wget -O sstp "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/ssh/sstp.sh" # Ini hanya installer pendukung
chmod +x sstp

# Membuat Direktori Konfigurasi
mkdir -p /etc/accel-ppp
mkdir -p /var/log/accel-ppp

# 3. Membuat Konfigurasi Utama accel-ppp.conf
cat > /etc/accel-ppp.conf << END
[modules]
log_file
log_syslog
#pptp
#l2tp
sstp
chap-secrets
auth_mschap_v2
auth_mschap_v1
auth_chap_md5
auth_pap
ippool
pppd_compat

[core]
#thread-count=4

[common]

[chap-secrets]
chap-secrets=/home/sstp/sstp_account

[ppp]
min-mtu=1280
mtu=1400
mru=1400
mppe=prefer
ipv4=require
lcp-echo-interval=20
lcp-echo-timeout=120

#[pptp]
#verbose=1
#ip-pool=pptp
#ifname=pptp%d

#[l2tp]
#verbose=1
#mppe=deny
#host-name=accel-ppp
#secret=
#ip-pool=l2tp
#ifname=l2tp%d

[sstp]
#cert-hash-proto=sha1,sha256
#cert-hash-sha1=
#cert-hash-sha256=
#ssl-ecdh-curve=prime256v1
#ssl-prefer-server-ciphers=0
#ssl-dhparam=/home/sstp/dh.pem
#host-name=domain.tld
#http-error=allow
#timeout=60
port=444
accept=ssl
ssl-ciphers=DEFAULT
ssl-protocol=tls1,tls1.1,tls1.2,tls1.3
ssl-ca-file=/home/sstp/ca.crt
ssl-pemfile=/home/sstp/server.crt
ssl-keyfile=/home/sstp/server.key
ip-pool=sstp
ifname=sstp%d

[dns]
dns1=8.8.8.8
dns2=8.8.4.4

[client-ip-range]
0.0.0.0/0

[ip-pool]
gw-ip-address=xxxxxxxxx
attr=Framed-Pool
172.63.11.3-254,name=sstp
172.63.12.3-254,name=l2tp,next=sstp
172.63.13.3-254,name=pptp,next=l2tp

[pppd-compat]
ip-up=/etc/ppp/ip-up
ip-down=/etc/ppp/ip-down
radattr-prefix=/var/run/radattr

[log]
#log-debug=/dev/stdout
#syslog=accel-pppd,daemon
#log-tcp=127.0.0.1:3000
#color=1
#per-user-dir=per_user
#per-session-dir=per_session
#per-session=1
log-file=/var/log/accel-ppp/accel-ppp.log
log-emerg=/var/log/accel-ppp/emerg.log
log-fail-file=/var/log/accel-ppp/auth-fail.log
copy=1
level=3

[log-pgsql]
conninfo=user=log
log-table=log

[cli]
#password=123
#sessions-columns=ifname,username,ip,ip6,ip6-dp,type,state,uptime,uptime-raw,calling-sid,called-sid,sid,comp,rx-bytes,tx-bytes,rx-bytes-raw,tx-bytes-raw,rx-pkts,tx-pkts
verbose=1
telnet=127.0.0.1:2000
tcp=127.0.0.1:2001  
END

# 4. Membuat Service Systemd agar SSTP jalan otomatis
cat > /etc/systemd/system/sstp.service << END
[Unit]
Description=SSTP Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/accel-pppd -d -p /var/run/accel-pppd.pid -c /etc/accel-ppp.conf
PIDFile=/var/run/accel-pppd.pid
Restart=always

[Install]
WantedBy=multi-user.target
END

# 5. Mengatur Firewall IPTables untuk SSTP
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 444 -j ACCEPT
iptables -I FORWARD -s 192.168.100.0/24 -j ACCEPT
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o $NIC -j MASQUERADE
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# 6. Menjalankan Service
systemctl daemon-reload
enable sstp
systemctl start sstp
systemctl restart sstp

echo -e "${GREEN}Instalasi SSTP VPN Selesai pada Port 444!${NC}"

