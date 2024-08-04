import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'auth_service.dart';
import 'daemon_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _status = 'Disconnected';
  bool _isConnecting = false;
  String? _authToken;
  ConfettiController? _confettiController;

  @override
  void initState() {
    super.initState();
    _fetchAuthToken();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    super.dispose();
  }

  Future<void> _fetchAuthToken() async {
    try {
      final token = await AuthService.fetchAuthToken();
      setState(() {
        _authToken = token;
      });
      if (_authToken == null) {
        print('No auth token received');
      } else {
        print('Received auth token: $_authToken');
      }
    } catch (e) {
      print('Failed to fetch token: $e');
    }
  }

  Future<void> _connect() async {
    if (_authToken == null) {
      print('No auth token available');
      return;
    }
    setState(() {
      _isConnecting = true;
    });
    try {
      final result = await DaemonService.connect(_authToken!);
      setState(() {
        _status = result ?? 'Unknown status';
      });
      if (_status == 'connected') {
        _confettiController?.play();
      }
    } catch (e) {
      print("Failed to connect: '$e'.");
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _disconnect() async {
    try {
      await DaemonService.disconnect();
      setState(() {
        _status = 'disconnected';
      });
      _confettiController?.stop();
    } catch (e) {
      print("Failed to disconnect: '$e'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.grey],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome!🚀',
                    style: GoogleFonts.pacifico(fontSize: 48, color: Colors.white),
                  ),
                                    Text(
                    'Let\'s get connected \n hit the button \n below to get started!🚀',
                    style: GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Status: $_status',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isConnecting
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: _authToken == null ? null : _connect,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300], // Silver background
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              child: const Text(
                                'Connect',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _disconnect,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300], // Silver background
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              child: const Text(
                                'Disconnect',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController!,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color.fromARGB(255, 235, 22, 7),
                  Color.fromARGB(255, 16, 127, 218),
                  Color.fromARGB(255, 38, 201, 44),
                  Color.fromARGB(255, 241, 223, 61),
                  Color.fromARGB(255, 199, 24, 230),
                  Color.fromARGB(255, 227, 145, 21),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
