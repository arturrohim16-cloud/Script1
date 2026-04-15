#!/usr/bin/env python3
import socket, threading, sys, time

# --- Konfigurasi AJI SYSTEM ---
LISTENING_ADDR = '0.0.0.0'
try:
    LISTENING_PORT = int(sys.argv[1])
except:
    LISTENING_PORT = 80 # Default port jika tidak ada input

BUFLEN = 4096 * 4
TIMEOUT = 60
DEFAULT_HOST = '127.0.0.1:1194' # Target ke OpenVPN

# Response standar WebSocket
RESPONSE = b'HTTP/1.1 101 Switching Protocols\r\n\r\nContent-Length: 104857600000\r\n\r\n'

class Server:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.running = False

    def start(self):
        self.soc = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            self.soc.bind((self.host, self.port))
        except Exception as e:
            print(f"Gagal Bind Port {self.port}: {e}")
            sys.exit(1)
        
        self.soc.listen(128)
        self.running = True
        print(f"Proxy OpenVPN Running on {self.host}:{self.port} -> Target {DEFAULT_HOST}")
        
        try:
            while self.running:
                client, addr = self.soc.accept()
                threading.Thread(target=self.handler, args=(client, addr), daemon=True).start()
        except KeyboardInterrupt:
            self.running = False
            self.soc.close()

    def handler(self, client, addr):
        try:
            client.settimeout(TIMEOUT)
            data = client.recv(BUFLEN)
            if not data: return

            # Koneksi ke Target (OpenVPN)
            target = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            host, port = DEFAULT_HOST.split(':')
            target.connect((host, int(port)))
            
            # Kirim balasan 101 ke Client
            client.sendall(RESPONSE)
            
            # Bridging Data
            self.forward(client, target)
        except:
            pass
        finally:
            client.close()

    def forward(self, source, destination):
        def bridge(src, dst):
            try:
                while True:
                    payload = src.recv(BUFLEN)
                    if not payload: break
                    dst.sendall(payload)
            except:
                pass
            finally:
                src.close()
                dst.close()

        threading.Thread(target=bridge, args=(source, destination), daemon=True).start()
        bridge(destination, source)

if __name__ == '__main__':
    print("\n:------- PYTHON PROXY V3 (OPENVPN) -------:\n")
    proxy = Server(LISTENING_ADDR, LISTENING_PORT)
    proxy.start()
          
