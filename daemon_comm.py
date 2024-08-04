import sys
import json
import socket

SOCKET_PATH = "/tmp/daemon-lite"

def send_request(request):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.connect(SOCKET_PATH)
        request_data = json.dumps(request).encode('utf-8')
        size = len(request_data)
        sock.sendall(size.to_bytes(8, byteorder='little'))
        sock.sendall(request_data)
        response_size_bytes = sock.recv(8)
        response_size = int.from_bytes(response_size_bytes, byteorder='little')
        response_data = sock.recv(response_size)
        return response_data.decode('utf-8')

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"status": "error", "message": "No command provided"}))
        return

    command = sys.argv[1]
    auth_token = sys.argv[2] if len(sys.argv) > 2 else None

    if command == "connect":
        response = send_request({"request": {"connect": int(auth_token)}})
    elif command == "disconnect":
        response = send_request({"request": "disconnect"})
    elif command == "get_status":
        response = send_request({"request": "get_status"})
    else:
        response = json.dumps({"status": "error", "message": "Unknown command"})

    print(response)

if __name__ == "__main__":
    main()
