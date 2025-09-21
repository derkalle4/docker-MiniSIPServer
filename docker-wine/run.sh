#!/bin/bash
cd /opt/sipserver

# info output
echo "Running on:"
echo "$(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
wine --version

# start xvfb
if [[ $XVFB == 1 ]]; then
    Xvfb :99 -nolisten tcp -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

# Trap SIGTERM (sent by docker stop) and SIGINT (Ctrl+C)
trap 'cleanup' SIGTERM SIGINT

# install winetricks dependencies if wineprefix is not initialized
if [ ! -d "/opt/sipserver/.wine" ]; then
    echo "Wine prefix not found. Initializing..."
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /opt/sipserver/winetricks
    chmod +x /opt/sipserver/winetricks
    /opt/sipserver/winetricks -q vcrun2019
    rm -rf /opt/sipserver/sipserver/.cache/
    echo "Dependencies installed."
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
