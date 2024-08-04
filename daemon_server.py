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
            auth_token = data.get('authToken')

            # Simulate connection logic
            response = {
                "status": "success",
                "data": {"daemon_status": "connected"}
            }
            self._send_response(200, response)

        elif self.path == '/disconnect':
            # Simulate disconnection logic
            response = {
                "status": "success",
                "data": {"daemon_status": "disconnected"}
            }
            self._send_response(200, response)

        else:
            self._send_response(404, {"status": "error", "message": "Not Found"})

    def do_GET(self):
        if self.path == '/status':
            # Simulate status check
            response = {
                "status": "success",
                "data": {"daemon_status": "connected"}
            }
            self._send_response(200, response)
        else:
            self._send_response(404, {"status": "error", "message": "Not Found"})

if __name__ == '__main__':
    server_address = ('', 5003)  # Port 5003
    httpd = HTTPServer(server_address, RequestHandler)
    print('Running server on port 5003...')
    httpd.serve_forever()


