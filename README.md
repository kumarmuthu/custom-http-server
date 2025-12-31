# Custom HTTP Server

![Python](https://img.shields.io/badge/python-3.x-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macOS-lightgrey.svg)
[![Build Status](https://github.com/kumarmuthu/custom-http-server/actions/workflows/python-app.yml/badge.svg)](https://github.com/kumarmuthu/custom-http-server/actions/workflows/python-app.yml)

![GitHub Forks](https://img.shields.io/github/forks/kumarmuthu/custom-http-server?style=for-the-badge)
![GitHub Stars](https://img.shields.io/github/stars/kumarmuthu/custom-http-server?style=for-the-badge)
![GitHub Contributors](https://img.shields.io/github/contributors/kumarmuthu/custom-http-server?style=for-the-badge)


A lightweight, Python-based **Custom HTTP Server** that runs as a **Linux systemd service** or a **macOS `launchd` agent**. Ideal for serving static files, logs, test results, or internal documentation.
This is a minimal yet powerful **custom HTTP server** written in pure Python. It includes MIME-type awareness and seamless integration with **systemd (Linux)** and **launchd (macOS)** for automatic startup on boot.

---

## ✅ Features

- **Pure Python** (no external dependencies)
- Serves any local directory
- MIME-type aware (e.g., `.log`, `.tap`, `.xml`, `.html`, `.pdf`, `.md`, etc.)
- Works as:
  - A **systemd service** on Linux
  - A **launchd agent** on macOS
- Runs on startup
- Configurable via a simple config or plist

---

## Directory Structure

```
custom-http-server/
├── custom-http-server/
│   ├── custom-http-server.service       # systemd unit file (Linux)
│   ├── custom_http_server.py            # Main HTTP server script
│   ├── default-config.conf              # Default configuration (path/port)
│   ├── install.sh                       # Installer script (Linux & macOS)
│   ├── macos-launchd-setup.sh           # macOS launchd agent setup
│   └── uninstall.sh                     # Uninstaller script
├── LICENSE                              # MIT License
└── README.md                            # Project documentation
```

---

## 🐧 Linux Installation (Systemd Service)

```bash
git clone https://github.com/kumarmuthu/custom-http-server.git
cd custom-http-server/custom-http-server
chmod +x install.sh uninstall.sh
sudo ./install.sh
```
> 🛡️ **Note:** `sudo` is required to install files in system paths like `/opt` or `/usr/local`.

---

### 🔧 Configure Port and Directory

Edit the config file:

```bash
sudo vi /etc/custom-http-server.conf
```

Example:

```ini
# Path to serve (change this to your target directory)
SERVE_PATH=/root
SERVE_PORT=80
```

* Port `80` requires **root** privileges (already handled by systemd).
* You can use any non-privileged port like `8080`, `8000`, etc., without root.

Restart to apply changes:

```bash
sudo systemctl restart custom-http-server
```

---

### ✅ Verify

```bash
sudo systemctl status custom-http-server
sudo lsof -i :80   # Or your configured port
```

Check service status to confirm it's running properly:

```bash
sudo systemctl status custom-http-server
```

---

### 📜 Logs

```bash
sudo journalctl -u custom-http-server -f
```

---

### 🔓 Allow Port in Firewall

#### On **Rocky Linux**:

```bash
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload
```

#### On **Ubuntu**:

```bash
sudo ufw allow 80/tcp
sudo ufw reload
```

---

### ❌ Uninstall (Linux)

```bash
cd custom-http-server/custom-http-server
sudo ./uninstall.sh
```

> 🛡️ **Note:** `sudo` is required to remove system files and services.

---

## 🍏 macOS Installation (launchd Agent)

```bash
git clone https://github.com/kumarmuthu/custom-http-server.git
cd custom-http-server/custom-http-server
chmod +x install.sh uninstall.sh macos-launchd-setup.sh
```

```bash
sudo ./install.sh -path /Users/<username> -port 8080
```

> 🛡️ **Note:** `sudo` is required to install files in system paths like `/opt` or `/usr/local`.

* `--path` → Directory to serve
* `--port` → HTTP port to use (e.g., 8080)

The script installs a `launchd` service and autostarts it.

---

### ✅ Verify & Logs (macOS)

Check if service is running:

```bash
launchctl list | grep custom_http_server
```

Validate plist syntax (optional):
```bash
plutil ~/Library/LaunchAgents/com.custom_http_server.plist
```

Example:
```
muthukumar@muthukumar custom-http-server % plutil /Users/muthukumar/Library/LaunchAgents/com.custom_http_server.plist
/Users/muthukumar/Library/LaunchAgents/com.custom_http_server.plist: OK
muthukumar@muthukumar custom-http-server % 
```

Watch logs in real time:

```bash
watch "cat /tmp/custom_httpserver.log"
```

Or using `tail`

```bash
tail -f /tmp/custom_httpserver.log
```

Example `.log` log:

```
muthukumar@muthukumar custom-http-server % cat /tmp/custom_httpserver.log      
#########Script Start#########
Resolved serve path:/root /root
Observed exception is: Invalid directory: /root
##########Script End##########
#########Script Start#########
Resolved serve path:/U /U
Observed exception is: Invalid directory: /U
##########Script End##########
#########Script Start#########
Resolved serve path:/Users /Users
Observed exception is: [Errno 48] Address already in use
##########Script End##########
#########Script Start#########
Resolved serve path:/Users/muthukumar /Users/muthukumar
Observed exception is: [Errno 48] Address already in use
##########Script End##########
muthukumar@muthukumar custom-http-server %
```

Or **error** logs:

```bash
watch "cat /tmp/custom_httpserver.err"
```

Or using `tail`

```bash
tail -f /tmp/custom_httpserver.err
```

Example `.err` log:

```
muthukumar@muthukumar custom-http-server % cat /tmp/custom_httpserver.err         
10.138.237.56 - - [21/Jun/2025 02:15:19] "GET /Documents/ HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:15:20] "GET /Documents/ HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:15:21] "GET /Documents/Screenshot%202024-12-06%20at%202.21.59%E2%80%AFPM.png HTTP/1.1" 200 -
127.0.0.1 - - [21/Jun/2025 02:23:27] "GET / HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:23:31] "GET /Documents/ HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:23:32] "GET /Documents/AMD/ HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:23:35] "GET /Documents/AMD/Ubuntu%20VM%20OS%20install.txt HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:29:02] "GET /Documents/AMD/Ubuntu%20VM%20OS%20install.txt HTTP/1.1" 304 -
10.138.237.56 - - [21/Jun/2025 02:29:05] "GET /Documents/AMD/Nutanix_Int_session.txt HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:36:41] "GET /Documents/AMD/Notes5.1.txt HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:42:41] "GET /Documents/ HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:42:43] "GET /Documents/Nutanix/ HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:42:45] "GET /Documents/Nutanix/Notes5.txt HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 02:45:10] "GET /Documents/Nutanix/Install_java.txt HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 03:12:54] "GET / HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 03:12:54] code 404, message File not found
10.138.237.56 - - [21/Jun/2025 03:12:54] "GET /favicon.ico HTTP/1.1" 404 -
10.138.237.56 - - [21/Jun/2025 03:42:44] "GET / HTTP/1.1" 200 -
10.138.237.56 - - [21/Jun/2025 03:42:47] "GET /Documents/ HTTP/1.1" 200 -
muthukumar@muthukumar custom-http-server %
```

---

### ❌ Uninstall (macOS)

✅ **Automated (recommended):**

```bash
cd custom-http-server/custom-http-server
sudo ./uninstall.sh
```

> 🛡️ **Note:** `sudo` is required to remove system files and services.

---

🛠️ **Manual (if needed):**

```bash
launchctl unload ~/Library/LaunchAgents/com.custom_http_server.plist
rm -f ~/Library/LaunchAgents/com.custom_http_server.plist
launchctl list | grep custom_http_server
```

✅ The final command `launchctl list | grep custom_http_server` should return nothing.

---

## ✅ Final Notes

* Works on **Linux (systemd)** and **macOS (launchd)**
* Built with **pure Python 3**
* No external dependencies
* Easily configurable

---

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
You are free to use, modify, and distribute it with attribution.

---

## Author

Developed and maintained by \[Muthukumar S]
GitHub: [https://github.com/kumarmuthu/](https://github.com/kumarmuthu/)

---
