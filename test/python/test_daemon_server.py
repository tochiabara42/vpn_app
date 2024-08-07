import unittest
import json
import threading
from http.server import HTTPServer
from unittest.mock import patch
import urllib.request
import daemon_server  # Ensure this module is importable

class TestDaemonServer(unittest.TestCase):

    @classmethod
    def setUpClass(cls):

        #  HTTP server with dynamic port
        cls.server_address = ('localhost', 0)
        cls.httpd = HTTPServer(cls.server_address, daemon_server.RequestHandler)
        # Get the dynamically assigned port
        cls.port = cls.httpd.server_address[1]
        # Start the server in a separate thread
        cls.server_thread = threading.Thread(target=cls.httpd.serve_forever)
        cls.server_thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.httpd.shutdown()
        cls.server_thread.join()

    @patch('urllib.request.urlopen')
    def test_connect(self, mock_urlopen):

        # Mock the response from the server
        mock_urlopen.return_value.read.return_value = json.dumps({
            "status": "success",
            "data": {"daemon_status": "connected"}
        }).encode('utf-8')
        
        # Send the request and get the response
        response = urllib.request.urlopen(f'http://localhost:{self.port}/connect', 
                                           data=json.dumps({"authToken": "1234"}).encode('utf-8')).read().decode('utf-8')
        
        # Expected response
        expected_response = '{"status": "success", "data": {"daemon_status": "connected"}}'
        
        # Assert the response is as expected
        self.assertEqual(response, expected_response)

    @patch('urllib.request.urlopen')
    def test_disconnect(self, mock_urlopen):

        # Mock the response from the server
        mock_urlopen.return_value.read.return_value = json.dumps({
            "status": "success",
            "data": {"daemon_status": "disconnected"}
        }).encode('utf-8')
        
        # Send the request and get the response
        response = urllib.request.urlopen(f'http://localhost:{self.port}/disconnect').read().decode('utf-8')
        
        # Expected response
        expected_response = '{"status": "success", "data": {"daemon_status": "disconnected"}}'
        
        # Assert the response is as expected
        self.assertEqual(response, expected_response)

    @patch('urllib.request.urlopen')
    def test_status(self, mock_urlopen):

        # Mock the response from the server
        mock_urlopen.return_value.read.return_value = json.dumps({
            "status": "success",
            "data": {"daemon_status": "connected"}
        }).encode('utf-8')
        
        # Send the request and get the response
        response = urllib.request.urlopen(f'http://localhost:{self.port}/status').read().decode('utf-8')
        
        # Expected response
        expected_response = '{"status": "success", "data": {"daemon_status": "connected"}}'
        
        # Assert the response is as expected
        self.assertEqual(response, expected_response)

if __name__ == '__main__':
    unittest.main()



