import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:vpn_app/authentication.dart';
import 'mocks/http_mock.mocks.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    Authentication.client = mockClient; // Use the mock client
  });

  group('AuthService Tests', () {
    test('fetchAuthToken returns a token if the response is successful', () async {
      //
      final response = jsonEncode({
        'status': 'success',
        'data': {'auth_token': 'mocked_token'}
      });
      when(mockClient.get(
        Uri.parse('https://warp-registration.warpdir2792.workers.dev/'),
        headers: {'X-Auth-Key': '3735928559'}
      )).thenAnswer((_) async => http.Response(response, 200));

      // Act
      final token = await Authentication.fetchAuthToken();

      // Assert
      expect(token, 'mocked_token');
    });

    test('fetchAuthToken returns null if the status is not success', () async {
      // Arrange
      final response = jsonEncode({
        'status': 'error',
        'message': 'Failed'
      });
      when(mockClient.get(
        Uri.parse('https://warp-registration.warpdir2792.workers.dev/'),
        headers: {'X-Auth-Key': '3735928559'}
      )).thenAnswer((_) async => http.Response(response, 200));

      // Act
      final token = await Authentication.fetchAuthToken();

      // Assert
      expect(token, isNull);
    });

    test('fetchAuthToken returns null if the HTTP response is not 200', () async {
      // Arrange
      when(mockClient.get(
        Uri.parse('https://warp-registration.warpdir2792.workers.dev/'),
        headers: {'X-Auth-Key': '3735928559'}
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      // Act
      final token = await Authentication.fetchAuthToken();

      // Assert
      expect(token, isNull);
    });
  });
}



