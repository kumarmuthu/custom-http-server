#!/bin/bash

echo "Stopping custom-http-server service..."
sudo systemctl stop custom-http-server

echo "Disabling custom-http-server service..."
sudo systemctl disable custom-http-server

echo "Killing any remaining custom-http-server Python processes..."
sudo pkill -f "/opt/custom-http-server/custom_http_server.py"

echo "Removing systemd service file..."
sudo rm -f /etc/systemd/system/custom-http-server.service

echo "Removing config file..."
sudo rm -f /etc/custom-http-server.conf

echo "Removing installed files from /opt/custom-http-server..."
sudo rm -rf /opt/custom-http-server

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Uninstall complete."
