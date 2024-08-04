import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _apiUrl = 'https://warp-registration.warpdir2792.workers.dev/';
  static const String _apiKey = '3735928559';

  static Future<String?> fetchAuthToken() async {
    final response = await http.get(
      Uri.parse(_apiUrl),
      headers: {'X-Auth-Key': _apiKey},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        return responseData['data']['auth_token'].toString();
      } else {
        print('Error fetching token: ${responseData['message']}');
        return null;
      }
    } else {
      print('Failed to fetch token');
      return null;
    }
  }
}



