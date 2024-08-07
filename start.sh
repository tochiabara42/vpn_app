#!/bin/bash

# Start the Python server 
echo "Starting Python server..."
python3 daemon_server.py &

SERVER_PID=$!

# Loading...
sleep 2

# Start the Flutter app
echo "Starting Flutter app..."
flutter run

# When Flutter app stops, stop/kill the Python server
echo "Stopping Python server..."
kill $SERVER_PID


