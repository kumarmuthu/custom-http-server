#!/bin/bash
set -e

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -path)
      SERVE_PATH="$2"
      shift 2
      ;;
    -port)
      PORT="$2"
      shift 2
      ;;
    *)
      echo "❌ Unknown option: $1"
      exit 1
      ;;
  esac
done

# Define paths and interpreter
# Destination for the launchd plist
PLIST_PATH="$HOME/Library/LaunchAgents/com.custom_http_server.plist"
SCRIPT_PATH="/usr/local/custom_http_server/custom_http_server.py"
PYTHON_PATH="$(which python3)"

echo "Python Path: $PYTHON_PATH"
echo "Script Path: $SCRIPT_PATH"

mkdir -p "$(dirname "$PLIST_PATH")"

# Create the launchd plist XML content
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.custom_http_server.python</string>
  <key>ProgramArguments</key>
  <array>
    <string>$PYTHON_PATH</string>
    <string>$SCRIPT_PATH</string>
    <string>--path</string>
    <string>$SERVE_PATH</string>
    <string>--port</string>
    <string>$PORT</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/custom_httpserver.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/custom_httpserver.err</string>
</dict>
</plist>
EOF

# Unload the plist if already loaded (ignore errors), then load the new version
echo "✅ launchd plist created at $PLIST_PATH"
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

# Notify user
echo "✅ Loaded com.custom_httpserver.python service. To verify: launchctl list | grep custom_http_server"
