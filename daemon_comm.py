import sys
import json
import socket

# Path to the UNIX domain socket
SOCKET_PATH = "/tmp/daemon-lite"

def send_request(request):


    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        #Connect to the socket at `tmp/daemon-lite`
        sock.connect(SOCKET_PATH)
        #Convert the req dictionary to a JSON string and encode it to bytes
        request_data = json.dumps(request).encode('utf-8')
        #Send the size of the req data as an 8-byte little-endian integer
        size = len(request_data)
        sock.sendall(size.to_bytes(8, byteorder='little'))
        #Send the req data
        sock.sendall(request_data)
        #Receives the size of the res data (first 8 bytes)
        response_size_bytes = sock.recv(8)
        response_size = int.from_bytes(response_size_bytes, byteorder='little')
        #Receive the res data
        response_data = sock.recv(response_size)
        #Return the decoded res data --> from bytes to a string
        return response_data.decode('utf-8')

def main():
    #Check if at least 1 command-line arg is provided
    if len(sys.argv) < 2:
        print(json.dumps({"status": "error", "message": "No command provided"}))
        return
    
    #Get the command from the first arg
    command = sys.argv[1]

    #Get the auth token from second arg if provided
    auth_token = sys.argv[2] if len(sys.argv) > 2 else None

    #handle `connect` command
    if command == "connect":
        response = send_request({"request": {"connect": int(auth_token)}})
    
    #handle `disconnect` command
    elif command == "disconnect":
        response = send_request({"request": "disconnect"})
    else:
        response = json.dumps({"status": "error", "message": "Unknown command"})

    print(response)

if __name__ == "__main__":
    main()
