import 'dart:convert';
import 'package:http/http.dart' as http;

//The daemon_service typically manages the connection to a service, such as VPN, and handles actions like connecting and disconnecting
class Daemon {
  static http.Client client = http.Client(); 
  static const String _serverUrl = 'http://localhost:5003';

//Logic to connect to the service using the auth token
  static Future<String?> connect(String authToken) async {
    try {
      final response = await client.post(
        Uri.parse('$_serverUrl/connect'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'authToken': authToken}),
      );

      print('Connect Response Status Code: ${response.statusCode}');
      print('Connect Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            return responseData['data']['daemon_status'];
          } else {
            print('Error in response: ${responseData['message']}');
            return null;
          }
        } catch (e) {
          print('Error parsing JSON: $e');
          return null;
        }
      } else {
        print('Failed to connect with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during connect request: $e');
      return null;
    }
  }

//Logic to disconnect from the service
  static Future<void> disconnect() async {
    try {
      final response = await client.post(
        Uri.parse('$_serverUrl/disconnect'),
      );

      print('Disconnect Response Status Code: ${response.statusCode}');
      print('Disconnect Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            print('Disconnected successfully');
          } else {
            print('Error in response: ${responseData['message']}');
          }
        } catch (e) {
          print('Error parsing JSON: $e');
        }
      } else {
        print('Failed to disconnect with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during disconnect request: $e');
    }
  }

  static Future<String?> getStatus() async {
    try {
      final response = await client.get(
        Uri.parse('$_serverUrl/status'),
      );

      print('Get Status Response Status Code: ${response.statusCode}');
      print('Get Status Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            return responseData['data']['daemon_status'];
          } else {
            print('Error in response: ${responseData['message']}');
            return null;
          }
        } catch (e) {
          print('Error parsing JSON: $e');
          return null;
        }
      } else {
        print('Failed to get status with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during getStatus request: $e');
      return null;
    }
  }
}



