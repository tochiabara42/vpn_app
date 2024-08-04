import 'dart:convert';
import 'package:http/http.dart' as http;

class DaemonService {
  static const String _serverUrl = 'http://localhost:5003';  // Ensure this matches your Python server URL

  static Future<String?> connect(String authToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/connect'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'authToken': authToken}),
      );

      // Debugging output
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

  static Future<void> disconnect() async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/disconnect'),
      );

      // Debugging output
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
      final response = await http.get(
        Uri.parse('$_serverUrl/status'),
      );

      // Debugging output
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


