#!/bin/bash
set -e

TARGET_DIR="/opt/custom_http_server"
CONFIG_PATH="/etc/custom-http-server.conf"
SERVICE_PATH="/etc/systemd/system/custom-http-server.service"

echo "Installing Custom HTTP Server..."

# Detect OS
OS_NAME="$(uname)"

# macOS adjustments
if [[ "$OS_NAME" == "Darwin" ]]; then
    TARGET_DIR="/usr/local/custom_http_server"
    CONFIG_PATH="/usr/local/etc/custom-http-server.conf"
fi

# Create target and config directories
sudo mkdir -p "$TARGET_DIR"
sudo mkdir -p "$(dirname "$CONFIG_PATH")"

# Copy application and config files
sudo cp custom_http_server.py "$TARGET_DIR/"
sudo cp default-config.conf "$CONFIG_PATH"

if [[ "$OS_NAME" == "Linux" ]]; then
    sudo cp custom-http-server.service "$SERVICE_PATH"
    sudo systemctl daemon-reload
    sudo systemctl enable custom-http-server
    sudo systemctl start custom-http-server

    echo "✅ Installed and started custom-http-server as a systemd service."
    echo "Edit $CONFIG_PATH to change path or port."
    echo "Logs: sudo journalctl -u custom-http-server -f"

elif [[ "$OS_NAME" == "Darwin" ]]; then
    echo "✅ Installed on macOS."
    echo "To run manually: python3 $TARGET_DIR/custom_http_server.py"
    echo "To make it a service, create a launchd plist manually."

else
    echo "❌ Unsupported OS: $OS_NAME"
    exit 1
fi
