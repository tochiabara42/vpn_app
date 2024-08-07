from http.server import BaseHTTPRequestHandler, HTTPServer
import json

class RequestHandler(BaseHTTPRequestHandler):
    def _send_response(self, status_code, response_data):

        self.send_response(status_code)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(response_data).encode('utf-8'))

    def do_POST(self):
        if self.path == '/connect':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            #extract the auth token from the data
            auth_token = data.get('authToken')

            # Simulate connection logic and prepare the response
            response = {
                "status": "success",
                "data": {"daemon_status": "connected"}
            }
             # Send the response with status code 200 (OK)
            self._send_response(200, response)

        elif self.path == '/disconnect':
            # Simulate disconnection logic and prepare response
            response = {
                "status": "success",
                "data": {"daemon_status": "disconnected"}
            }
            self._send_response(200, response)

        else:
            # Send a 404 Not Found response for unsupported paths
            self._send_response(404, {"status": "error", "message": "Not Found"})

    def do_GET(self):
        if self.path == '/status':
            # Simulate status check logic and prepare response
            response = {
                "status": "success",
                "data": {"daemon_status": "connected"}
            }
            self._send_response(200, response)
        else:
            self._send_response(404, {"status": "error", "message": "Not Found"})

if __name__ == '__main__':
    # Define server address and port
    server_address = ('', 5003)  # Port 5003
    # Create the HTTP server
    httpd = HTTPServer(server_address, RequestHandler)
    print('Running server on port 5003...')
    httpd.serve_forever()


