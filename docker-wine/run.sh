#!/bin/bash
cd /opt/sipserver

# info output
echo "== Running on:"
echo "== $(cat /etc/debian_version)"
echo "== Current timezone: $(cat /etc/timezone)"
wine --version

# Trap SIGTERM (sent by docker stop) and SIGINT (Ctrl+C)
cleanup() {
    echo "== Cleaning up..."
    
    # Kill the tail process if it exists
    if [ ! -z "$TAIL_PID" ]; then
        kill $TAIL_PID 2>/dev/null
        echo "== Stopped log monitoring"
    fi
    
    # Kill the main application if it exists
    if [ ! -z "$APP_PID" ]; then
        kill $APP_PID 2>/dev/null
        echo "== Stopped main application"
        # Give it a moment to exit gracefully
        sleep 2
        # Force kill if still running
        kill -9 $APP_PID 2>/dev/null
    fi
    
    # Kill any remaining wine processes
    pkill -f wine 2>/dev/null
    pkill -f minisipserver 2>/dev/null
    
    echo "== Cleanup complete"
    exit 0
}
trap 'cleanup' SIGTERM SIGINT

# install winetricks dependencies if wineprefix is not initialized
if [ ! -d "/opt/sipserver/.wine" ]; then
    echo "== Wine prefix not found. Initializing..."
    
    # Initialize wine prefix using wineboot (headless alternative to winecfg)
    echo "== Initializing Wine prefix with wineboot..."

    # Download and install winetricks
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /opt/sipserver/winetricks
    chmod +x /opt/sipserver/winetricks
    
    # Install dependencies
    echo "== Installing Wine dependencies..."
    /opt/sipserver/winetricks -q corefonts vcrun2019
    
    # Clean up
    rm -rf /opt/sipserver/.cache/ 2>/dev/null
    echo "== Dependencies installed."
else
    echo "== Wine prefix found, skipping initialization."
fi

# Start the main application in the background
echo "== Starting minisipserver (windows version)"
# Ensure the application exists before trying to run it
if [ -f "/opt/sipserver/minisipserver-cli.exe" ]; then
  wine /opt/sipserver/minisipserver-cli.exe &
  APP_PID=$!
  sleep 3 # Give the application some time to start
  # Monitor the latest log file in real-time
  LOG_DIR="/opt/sipserver/.wine/drive_c/users/container/AppData/Roaming/minisipserver/log"
  if [ -d "$LOG_DIR" ]; then
    echo "== Monitoring log files in $LOG_DIR"
    # Find the latest log file and tail it in the background
    while [ ! "$(find "$LOG_DIR" -name "*.log" -o -name "*.txt" 2>/dev/null | head -1)" ]; do
      echo "== Waiting for log file to be created..."
      sleep 2
    done
    
    # Get the latest log file and start tailing it
    LATEST_LOG=$(find "$LOG_DIR" -type f \( -name "*.log" -o -name "*.txt" \) -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
    if [ ! -z "$LATEST_LOG" ]; then
      echo "== Tailing log file: $LATEST_LOG"
      tail -f "$LATEST_LOG" &
      TAIL_PID=$!
    fi
  else
    echo "== Log directory not found, continuing without log monitoring"
  fi
  
  # Wait for the main application to exit
  wait $APP_PID
  
  # Clean up the tail process when main app exits
  if [ ! -z "$TAIL_PID" ]; then
    kill $TAIL_PID 2>/dev/null
  fi
else
  echo "== Error: /opt/sipserver/minisipserver-cli.exe not found. Did you copy the files correctly?"
  exit 1
fi
echo "== minisipserver (windows version) has exited. Script finishing."
