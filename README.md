# vpn_app 🖥️📱💻



## Overview

This project includes a Flutter app that interacts with a Python daemon. Below are the instructions for starting the application, running tests and managing the daemon. 

### Prerequisites

Ensure you have the following installed:

- Python 3
- Flutter SDK

### Starting the application

1. Start the Daemon:

Open a terminal and run the daemon using:

`tmp/daemon-lite`

2. Start the Python Server and Flutter App:

Open a second terminal and execute the provided 'start.sh' script:

`./start.sh`

The script will:

- Start the Python server in the background.
- Launch the Flutter app.
- Stop the Python server when the Flutter app exits.

## Testing

### Python Tests

To run Python tests, execute the following command:

`python -m unittest discover -s test/python -p 'test_*.py`

### Flutter Tests

To run Flutter tests, execute the following command:

`flutter test`

## Troubleshooting

If the Daemon refuses to start, check the permissions and the execute flag for `tmp/daemon-lite`. Ensure no other process is using the required port.

