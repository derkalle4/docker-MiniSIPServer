#!/bin/bash
cd /opt/sipserver

# info output
echo "== Running on:"
echo "== $(cat /etc/debian_version)"
echo "== Current timezone: $(cat /etc/timezone)"
wine --version

# start virtual display
if [[ $XVFB == 1 ]]; then
    if ! pgrep -f "Xvfb ${DISPLAY}" > /dev/null; then
        echo "== Starting Xvfb..."
        Xvfb ${DISPLAY} -nolisten tcp -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
        sleep 2  # Give Xvfb time to start
    else
        echo "== Xvfb is already running on display :0"
    fi
fi

# Trap SIGTERM (sent by docker stop) and SIGINT (Ctrl+C)
cleanup() {
    echo "== Cleaning up..."
    if [ ! -z "$APP_PID" ]; then
        kill $APP_PID 2>/dev/null
    fi
    pkill Xvfb 2>/dev/null
    exit 0
}
trap 'cleanup' SIGTERM SIGINT

# install winetricks dependencies if wineprefix is not initialized
if [ ! -d "/opt/sipserver/.wine" ]; then
    echo "== Wine prefix not found. Initializing..."
    
    # Initialize wine prefix using wineboot (headless alternative to winecfg)
    echo "== Initializing Wine prefix with wineboot..."
    wineboot --init
    
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
if [ -f "/opt/sipserver/minisipserver.exe" ]; then
  wine /opt/sipserver/minisipserver.exe &
  APP_PID=$!
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
  wait $APP_PID
else
  echo "== Error: /opt/sipserver/minisipserver.exe not found. Did you copy the files correctly?"
  exit 1
fi
echo "== minisipserver (windows version) has exited. Script finishing."
