#!/bin/bash

# Start the Python server in the background
echo "Starting Python server..."
python3 daemon_server.py &

# Save the process ID (PID) of the Python server
SERVER_PID=$!

# Wait a moment to ensure the server starts
sleep 2

# Start the Flutter app
echo "Starting Flutter app..."
flutter run

# When Flutter app stops, kill the Python server
echo "Stopping Python server..."
kill $SERVER_PID


