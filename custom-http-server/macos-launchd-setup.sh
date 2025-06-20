#!/bin/bash
set -e

PORT="$1"
SERVE_PATH="$2"

if [[ -z "$PORT" || -z "$SERVE_PATH" ]]; then
  echo "❌ Port and path are required."
  exit 1
fi

PLIST_PATH="$HOME/Library/LaunchAgents/com.custom.httpserver.plist"
TARGET_DIR="/usr/local/custom_http_server"

mkdir -p "$(dirname "$PLIST_PATH")"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.custom.httpserver</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/python3</string>
        <string>$TARGET_DIR/custom_http_server.py</string>
        <string>--path</string>
        <string>$SERVE_PATH</string>
        <string>--port</string>
        <string>$PORT</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>$TARGET_DIR</string>
    <key>StandardOutPath</key>
    <string>/tmp/custom_http_server.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/custom_http_server.err</string>
</dict>
</plist>
EOF

echo "✅ launchd plist created at $PLIST_PATH"
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"
echo "✅ Loaded into launchctl. Use 'launchctl list | grep custom.httpserver' to check."
