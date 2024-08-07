import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'authentication.dart';
import 'daemon.dart';

void main() {
  runApp(const VpnApp());
}

class VpnApp extends StatelessWidget {
  const VpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VpnHomePage(),
    );
  }
}

class VpnHomePage extends StatefulWidget {
  const VpnHomePage({super.key});

  @override
  VpnHomePageState createState() => VpnHomePageState();
}

class VpnHomePageState extends State<VpnHomePage> {
  String _status = 'disconnected';
  bool _isConnecting = false;
  String? _authToken;
  ConfettiController? _confettiController;
  bool _isLoading = true;
  bool _isButtonDisabled = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _fetchAuthToken();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

//Fuction to fetch auth token from api using the `Auth Service`
  Future<void> _fetchAuthToken() async {
    while (_authToken == null) {
      try {
        final token = await Authentication.fetchAuthToken();
        if (token != null) {
          setState(() {
            _authToken = token;
            _isLoading = false;
          });
          print('Received auth token: $_authToken');
        } else {
          print('No auth token received, retrying...');
          await Future.delayed(const Duration(seconds: 2)); // Wait before retrying
        }
      } catch (e) {
        print('Failed to fetch token: $e');
        await Future.delayed(const Duration(seconds: 2)); // Wait before retrying
      }
    }
  }

//Fuction to connect to the `Daemon Service` using the auth token from api 
  Future<void> _connect() async {
    if (_authToken == null) {
      print('No auth token available');  //If api doesn't return an auth token this will print on console
      return;
    }
    
    // Debounce button presses
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _isConnecting = true;
        _isButtonDisabled = true; 
      });

      try {
        Daemon.connect(_authToken!).then((result) {
          setState(() {
            _status = result ?? 'Unknown status';
          });
          //If Daemon is connected, confetti will appear on the screen
          if (_status == 'connected') {
            _confettiController?.play();
          }
        }).catchError((e) {
          print("Failed to connect: '$e'.");
        }).whenComplete(() {
          setState(() {
            _isConnecting = false;
            _isButtonDisabled = false; 
          });
        });
      } catch (e) {
        print("Failed to connect: '$e'.");
        setState(() {
          _isConnecting = false;
          _isButtonDisabled = false; 
        });
      }
    });
  }

//Fuction to disconnect from the `Daemon Service` 
  Future<void> _disconnect() async {
    try {
      await Daemon.disconnect();
   //If Daemon is disconnected, confetti should eventually stop
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
                    'Let\'s get connected, \n hit the button \n below to get started ☄️',
                    style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Status: $_status⚡',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const CircularProgressIndicator() // Show loading indicator while fetching auth token
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            //Once the `connect` button is pressed the connect function should run
                            onPressed: _isButtonDisabled ? null : _connect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 208, 203, 203), // Silver background
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
                            child: Text(
                              'CONNECT 🟢',
                              style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                             //Once the `disconnect` button is pressed the disconnect function should run
                            onPressed: _disconnect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 208, 203, 203), // Silver background
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
                            child: Text(
                              'DISCONNECT 🚫',
                              style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            //To prevent an issue with UI if auth token has not been received
            if (_isConnecting)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(), // Full-screen overlay
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

