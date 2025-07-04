#!/bin/bash
set -e

OS_NAME="$(uname)"

if [[ "$OS_NAME" == "Linux" ]]; then
  echo "Stopping custom-http-server service on Linux..."
  sudo systemctl stop custom-http-server || true

  echo "Disabling the service..."
  sudo systemctl disable custom-http-server || true

  echo "Killing any running Python server process..."
  sudo pkill -f "/opt/custom-http-server/custom_http_server.py" || true

  echo "Removing systemd service file..."
  sudo rm -f /etc/systemd/system/custom-http-server.service

  echo "Removing config file..."
  sudo rm -f /etc/custom-http-server.conf

  echo "Removing installed files from /opt/custom-http-server..."
  sudo rm -rf /opt/custom-http-server

  echo "Reloading systemd daemon..."
  sudo systemctl daemon-reload

  echo "Uninstall complete on Linux."

elif [[ "$OS_NAME" == "Darwin" ]]; then
  echo "Stopping custom-http-server (com.custom_http_server.python) service on macOS..."

  PLIST="$HOME/Library/LaunchAgents/com.custom_http_server.plist"
  TARGET_DIR="/usr/local/custom_http_server"
  CONFIG_PATH="/usr/local/etc/custom-http-server.conf"

  if [[ -f "$PLIST" ]]; then
    launchctl unload "$PLIST" 2>/dev/null || true
    echo "Unloaded service: $PLIST"
    rm -f "$PLIST"
    echo "Removed plist: $PLIST"
  fi

  echo "Removing installed script and config..."
  sudo rm -f "$TARGET_DIR/custom_http_server.py" || true
  sudo rm -f "$CONFIG_PATH" || true

  echo "Removing empty custom_http_server dir if exists..."
  sudo rmdir "$TARGET_DIR" 2>/dev/null || true

  echo "Cleaning up log files..."
  rm -f /tmp/custom_httpserver.log /tmp/custom_httpserver.err || true

  echo "Verifying removal..."
  launchctl list | grep custom_httpserver || echo "✅ Service fully removed."

  echo "Uninstall complete on macOS."

else
  echo "Unsupported OS: $OS_NAME"
  exit 1
fi
