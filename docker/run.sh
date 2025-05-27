#!/bin/bash
set -e

# Check if MiniSIPServer is already installed by checking for its directory
if [ ! -f "/opt/sipserver/minisipserver-cli" ]; then
  echo "MiniSIPServer executable /opt/sipserver/minisipserver-cli not found. Proceeding with installation..."
  
  export DEBIAN_FRONTEND=noninteractive

  echo "Updating package lists and installing prerequisites (wget, ca-certificates)..."
  apt-get update
  apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    qtbase5-dev \
    wget \
    ca-certificates

  echo "Downloading MiniSIPServer package..."
  wget https://www.myvoipapp.com/download/mss_$SRV_VERSION/amd64/mss_$SRV_VERSION_$SRV_TYPE_amd64.deb -O /tmp/mss_$SRV_VERSION_$SRV_TYPE_amd64.deb

  echo "Installing MiniSIPServer package..."
  dpkg --install /tmp/mss_$SRV_VERSION_$SRV_TYPE_amd64.deb

  if [ $? -ne 0 ]; then
    echo "dpkg installation failed. Attempting to fix dependencies..."
    apt-get install -f -y
  fi

  echo "Cleaning up downloaded package file..."
  rm /tmp/mss_$SRV_VERSION_$SRV_TYPE_amd64.deb

  echo "Performing cleanup (autoremove, clean apt cache)..."
  apt-get autoremove -y --purge
  apt-get clean -y
  rm -rf /var/lib/apt/lists/*
  
  echo "MiniSIPServer installation and cleanup complete."
else
  echo "MiniSIPServer already installed at /opt/sipserver/. Skipping installation."
fi

# Function to perform cleanup
cleanup() {

  echo "Received signal to stop. Running killall for minisipserver-cli..."
  if pgrep -f "/opt/sipserver/minisipserver-cli" > /dev/null; then
    killall minisipserver-cli
    # Wait a moment for graceful shutdown
    sleep 2
    # Force kill if it's still running
    if pgrep -f "/opt/sipserver/minisipserver-cli" > /dev/null; then
      echo "minisipserver-cli still running. Forcing kill with SIGKILL..."
      killall -9 minisipserver-cli
    else
      echo "minisipserver-cli terminated."
    fi
  else
    echo "minisipserver-cli not found running."
  fi
  echo "minisipserver-cli has exited. Script finishing."
  exit 0 # Exit the script gracefully
}

# Trap SIGTERM (sent by docker stop) and SIGINT (Ctrl+C)
trap 'cleanup' SIGTERM SIGINT

# Start the main application in the background
echo "Starting minisipserver-cli..."
# Ensure the application exists before trying to run it
if [ -f "/opt/sipserver/minisipserver-cli" ]; then
  /opt/sipserver/minisipserver-cli &
  APP_PID=$!
  wait $APP_PID
else
  echo "Error: /opt/sipserver/minisipserver-cli not found. Installation might have failed."
  exit 1
fi
echo "minisipserver-cli has exited. Script finishing."