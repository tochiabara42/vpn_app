import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:vpn_app/daemon.dart';
import 'mocks/http_mock.mocks.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    Daemon.client = mockClient; // Use the mock client
  });

  group('DaemonService Tests', () {
    test('connect returns daemon status if the response is successful', () async {
      // Arrange
      final response = jsonEncode({
        'status': 'success',
        'data': {'daemon_status': 'connected'}
      });
      when(mockClient.post(
        Uri.parse('http://localhost:5003/connect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'authToken': 'valid_token'})
      )).thenAnswer((_) async => http.Response(response, 200));

      // Act
      final status = await Daemon.connect('valid_token');

      // Assert
      expect(status, 'connected');
    });

    test('connect returns null if the response status is not success', () async {
      // Arrange
      final response = jsonEncode({
        'status': 'error',
        'message': 'Failed'
      });
      when(mockClient.post(
        Uri.parse('http://localhost:5003/connect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'authToken': 'valid_token'})
      )).thenAnswer((_) async => http.Response(response, 200));

      // Act
      final status = await Daemon.connect('valid_token');

      // Assert
      expect(status, isNull);
    });

    test('connect returns null if the HTTP response is not 200', () async {
      // Arrange
      when(mockClient.post(
        Uri.parse('http://localhost:5003/connect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'authToken': 'valid_token'})
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      // Act
      final status = await Daemon.connect('valid_token');

      // Assert
      expect(status, isNull);
    });

    test('disconnect prints success message if the response is successful', () async {
      // Arrange
      final response = jsonEncode({
        'status': 'success'
      });
      when(mockClient.post(
        Uri.parse('http://localhost:5003/disconnect'),
      )).thenAnswer((_) async => http.Response(response, 200));

      // Act
      await Daemon.disconnect();

      // Assert
      // Check that 'Disconnected successfully' is printed
      // This may require capturing stdout or using a logging framework
    });

    test('disconnect handles non-200 response', () async {
      // Arrange
      when(mockClient.post(
        Uri.parse('http://localhost:5003/disconnect'),
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      // Act
      await Daemon.disconnect();

      // Assert
      // Check that 'Failed to disconnect with status code: 404' is printed
      // This may require capturing stdout or using a logging framework
    });

    test('getStatus returns daemon status if the response is successful', () async {
      // Arrange
      final response = jsonEncode({
        'status': 'success',
        'data': {'daemon_status': 'running'}
      });
      when(mockClient.get(
        Uri.parse('http://localhost:5003/status'),
      )).thenAnswer((_) async => http.Response(response, 200));

      // Act
      final status = await Daemon.getStatus();

      // Assert
      expect(status, 'running');
    });

    test('getStatus returns null if the response status is not success', () async {
      // Arrange
      final response = jsonEncode({
        'status': 'error',
        'message': 'Failed'
      });
      when(mockClient.get(
        Uri.parse('http://localhost:5003/status'),
      )).thenAnswer((_) async => http.Response(response, 200));

      // Act
      final status = await Daemon.getStatus();

      // Assert
      expect(status, isNull);
    });

    test('getStatus returns null if the HTTP response is not 200', () async {
      // Arrange
      when(mockClient.get(
        Uri.parse('http://localhost:5003/status'),
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      // Act
      final status = await Daemon.getStatus();

      // Assert
      expect(status, isNull);
    });
  });
}
