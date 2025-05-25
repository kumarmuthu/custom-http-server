#!/bin/bash

set -e

TARGET_DIR="/opt/custom_http_server"

echo "Installing Custom HTTP Server..."

sudo mkdir -p $TARGET_DIR
sudo cp custom_http_server.py $TARGET_DIR/
sudo cp custom-http-server.service /etc/systemd/system/
sudo cp default-config.conf /etc/custom-http-server.conf

sudo systemctl daemon-reload
sudo systemctl enable custom-http-server
sudo systemctl start custom-http-server

echo "Installed and started custom-http-server."
echo "Edit /etc/custom-http-server.conf to change path or port."
echo "Logs: sudo journalctl -u custom-http-server -f"
