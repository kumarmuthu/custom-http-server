#!/bin/bash
set -e

# Default values
DEFAULT_TARGET_DIR="/usr/local/custom_http_server"
DEFAULT_CONFIG_PATH="/usr/local/etc/custom-http-server.conf"
DEFAULT_PORT=""
DEFAULT_PATH=""

# Parse macOS arguments
OS_NAME="$(uname)"
if [[ "$OS_NAME" == "Darwin" ]]; then
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -path)
        DEFAULT_PATH="$2"
        shift 2
        ;;
      -port)
        DEFAULT_PORT="$2"
        shift 2
        ;;

      *)
        echo "❌ Unknown argument: $1"
        exit 1
        ;;
    esac
  done

  if [[ -z "$DEFAULT_PATH" && -z "$DEFAULT_PORT" ]]; then
    echo "❌ Error: At least one of -path or -port must be specified."
    exit 1
  fi

fi

# Set platform-specific values
TARGET_DIR="/opt/custom_http_server"
CONFIG_PATH="/etc/custom-http-server.conf"
SERVICE_PATH="/etc/systemd/system/custom-http-server.service"

if [[ "$OS_NAME" == "Darwin" ]]; then
  TARGET_DIR="$DEFAULT_TARGET_DIR"
  CONFIG_PATH="$DEFAULT_CONFIG_PATH"
fi

echo "Installing Custom HTTP Server..."

# Create target and config directories
sudo mkdir -p "$TARGET_DIR"
sudo mkdir -p "$(dirname "$CONFIG_PATH")"

# Copy application and config files
sudo cp custom_http_server.py "$TARGET_DIR/"
sudo cp default-config.conf "$CONFIG_PATH"

if [[ "$OS_NAME" == "Linux" ]]; then
  echo "✅ Installing on Linux."
  sudo cp custom-http-server.service "$SERVICE_PATH"
  sudo systemctl daemon-reload
  sudo systemctl enable custom-http-server
  sudo systemctl start custom-http-server

  echo "✅ Installed and started custom-http-server as a systemd service."
  echo "Edit $CONFIG_PATH to change path or port."
  echo "Logs: sudo journalctl -u custom-http-server -f"

elif [[ "$OS_NAME" == "Darwin" ]]; then
  echo "✅ Installing on macOS."
  echo "Note: macOS does not support automatic install/uninstall like Linux (systemd)."
  echo "⚠️ To run manually:"
  echo "   python3 $TARGET_DIR/custom_http_server.py --path /Users/<your-username> --port <your-port>"
  echo "Replace <your-username> with your actual macOS username."
  echo "Choose a port that's not already in use (e.g., 8080, 8888, 3000, etc.)."
  echo "To make it a background service, create a launchd plist manually."

  # Fallback to config value if port was not passed
  if [[ -z "$DEFAULT_PORT" ]]; then
    echo "Reading port from config: $CONFIG_PATH"
    DEFAULT_PORT=$(grep '^SERVE_PORT=' "$CONFIG_PATH" | cut -d= -f2)
  fi

  # Fallback to config value if path was not passed
  if [[ -z "$DEFAULT_PATH" ]]; then
    echo "Reading path from config: $CONFIG_PATH"
    TEMP_PATH=$(grep '^SERVE_PATH=' "$CONFIG_PATH" | cut -d= -f2)

    # Skip using /root if on macOS
    if [[ "$OS_NAME" == "Darwin" && "$TEMP_PATH" == "/root" ]]; then
      echo "⚠️ Ignoring '/root' path on macOS. Please specify --path manually."
    else
      DEFAULT_PATH="$TEMP_PATH"
    fi
  fi


  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ ! -x "$SCRIPT_DIR/macos-launchd-setup.sh" ]]; then
    echo "❌ Error: macos-launchd-setup.sh is missing or not executable."
    ls -l "$SCRIPT_DIR/macos-launchd-setup.sh"
    exit 1
  fi

  chmod +x "$SCRIPT_DIR/macos-launchd-setup.sh"
  #  bash "$SCRIPT_DIR/macos-launchd-setup.sh" -path "$DEFAULT_PATH" -port "$DEFAULT_PORT"
  LAUNCHD_ARGS=()
  [[ -n "$DEFAULT_PATH" ]] && LAUNCHD_ARGS+=("-path" "$DEFAULT_PATH")
  [[ -n "$DEFAULT_PORT" ]] && LAUNCHD_ARGS+=("-port" "$DEFAULT_PORT")

  bash "$SCRIPT_DIR/macos-launchd-setup.sh" "${LAUNCHD_ARGS[@]}"


else
  echo "❌ Unsupported OS: $OS_NAME"
  exit 1
fi
