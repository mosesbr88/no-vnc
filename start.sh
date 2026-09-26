#!/bin/bash

set -e

DISPLAY_NUM="1"
DISPLAY=":${DISPLAY_NUM}"

# Railway provides PORT
PORT="${PORT:-8080}"

export DISPLAY

mkdir -p /root/.vnc

# VNC password
# Change this before using publicly.
VNC_PASSWORD="${VNC_PASSWORD:-change-me}"

echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# Remove old VNC locks if container restarted
rm -f /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1

# XFCE startup
cat > /root/.vnc/xstartup <<'EOF'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_CURRENT_DESKTOP=XFCE
export XDG_SESSION_DESKTOP=xfce
export XDG_CONFIG_DIRS=/etc/xdg/xdg-xfce:/etc/xdg
export XDG_DATA_DIRS=/usr/share/xfce4:/usr/share

dbus-launch --exit-with-session startxfce4
EOF

chmod +x /root/.vnc/xstartup

echo "Starting VNC..."

vncserver "$DISPLAY" \
    -geometry 1280x720 \
    -depth 24 \
    -localhost no

echo "Starting noVNC on port $PORT..."

# noVNC's web directory
NOVNC="/usr/share/novnc"

# Start websockify + noVNC
websockify \
    --web="$NOVNC" \
    "$PORT" \
    "localhost:5901" &

echo "================================="
echo "noVNC started"
echo "Port: $PORT"
echo "Display: $DISPLAY"
echo "================================="

# Keep container alive
wait
