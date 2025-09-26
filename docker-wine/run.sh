#!/bin/bash
cd /opt/sipserver

# info output
echo "Running on:"
echo "$(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
wine --version

# start xvfb first
if [[ $XVFB == 1 ]]; then
    echo "Starting Xvfb..."
    Xvfb :99 -nolisten tcp -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
    sleep 2  # Give Xvfb time to start
fi

# Trap SIGTERM (sent by docker stop) and SIGINT (Ctrl+C)
cleanup() {
    echo "Cleaning up..."
    if [ ! -z "$APP_PID" ]; then
        kill $APP_PID 2>/dev/null
    fi
    pkill Xvfb 2>/dev/null
    exit 0
}
trap 'cleanup' SIGTERM SIGINT

# install winetricks dependencies if wineprefix is not initialized
if [ ! -d "/opt/sipserver/.wine" ]; then
    echo "Wine prefix not found. Initializing..."
    
    # Initialize wine prefix using wineboot (headless alternative to winecfg)
    echo "Initializing Wine prefix with wineboot..."
    wineboot --init
    
    # Download and install winetricks
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /opt/sipserver/winetricks
    chmod +x /opt/sipserver/winetricks
    
    # Install dependencies
    echo "Installing Wine dependencies..."
    /opt/sipserver/winetricks -q corefonts vcrun2019 vcrun2022
    
    # Clean up
    rm -rf /opt/sipserver/.cache/ 2>/dev/null
    echo "Dependencies installed."
else
    echo "Wine prefix found, skipping initialization."
fi

# Start the main application in the background
echo "Starting minisipserver (windows version)"
# Ensure the application exists before trying to run it
if [ -f "/opt/sipserver/minisipserver.exe" ]; then
  wine /opt/sipserver/minisipserver.exe &
  APP_PID=$!
  wait $APP_PID
else
  echo "Error: /opt/sipserver/minisipserver.exe not found. Did you copy the files correctly?"
  exit 1
fi
echo "minisipserver (windows version) has exited. Script finishing."
