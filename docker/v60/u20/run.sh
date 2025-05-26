#!/bin/bash
set -e

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
/opt/sipserver/minisipserver-cli &

APP_PID=$!
wait $APP_PID
echo "minisipserver-cli has exited. Script finishing."