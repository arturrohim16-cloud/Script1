import socket
import threading
import select
import sys

# Konfigurasi Default
LISTENING_ADDR = '0.0.0.0'
TARGET_HOST = '127.0.0.1'
TARGET_PORT = 143  # Mengarah ke Dropbear

class Proxy:
    def __init__(self, client, address):
        self.client = client
        self.address = address
        self.target = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.client_buffer = b""
        self.run()

    def run(self):
        try:
            self.target.connect((TARGET_HOST, TARGET_PORT))
        except Exception as e:
            self.client.close()
            return

        self.client.setblocking(0)
        self.target.setblocking(0)
        
        while True:
            readable, writable, err = select.select([self.client, self.target], [], [self.client, self.target], 60)
            if err:
                break
            
            for s in readable:
                try:
                    data = s.recv(8192)
                    if not data:
                        break
                    if s is self.client:
                        # Mendukung Upgrade Websocket
                        if b"Upgrade: websocket" in data or self.client_buffer:
                            self.target.send(data)
                    else:
                        self.client.send(data)
                except:
                    break
            if not readable:
                break
        
        self.client.close()
        self.target.target.close()

def main(port):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        server.bind((LISTENING_ADDR, port))
    except Exception as e:
        print(f"Error: Gagal bind ke port {port}. Mungkin port sudah digunakan.")
        sys.exit(1)
        
    server.listen(1000)
    print(f"--- SSH Websocket Running on Port {port} ---")
    
    while True:
        try:
            client, address = server.accept()
            threading.Thread(target=Proxy, args=(client, address), daemon=True).start()
        except KeyboardInterrupt:
            break
        except:
            pass

if __name__ == '__main__':
    # Default port 8880 jika tidak ada argumen
    port_arg = int(sys.argv[1]) if len(sys.argv) > 1 else 8880
    main(port_arg)
  
