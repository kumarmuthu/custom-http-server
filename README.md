# Custom HTTP Server

A minimal, MIME-aware Python HTTP server with systemd integration.

## Features

- Written in **pure Python** using `http.server` (Python 3.x)
- Serves any directory (configured via `/etc/custom-http-server.conf`)
- Auto-starts on boot
- MIME types for `.log`, `.tap`, `.xml`, `.html`
- Written in pure Python using `http.server`

## Installation

```bash
git clone https://github.com/kumarmuthu/custom-http-server.git
cd custom-http-server/custom-http-server
chmod +x install.sh uninstall.sh
sudo ./install.sh
```

---

* To allow users to easily update the **port** and **path** used by the custom HTTP server, you’ve already provided a config file (`/etc/custom-http-server.conf`). Here's how they can update the **port** specifically:

## Step-by-Step: Update Port

1. **Open the config file:**

```bash
sudo vi /etc/custom-http-server.conf
```

2. **Change the value of `SERVE_PORT`:**

You're currently using port `80`, so your config will look like:

```ini
# Path to serve (change this to your target directory)
SERVE_PATH=/root
SERVE_PORT=80
```

> ℹ️ **Note:** Port `80` is the default HTTP port and requires the service to run as **root**. This is already handled by the systemd unit (`User=root`), so no additional configuration is required for privileged port access.

> For non-root ports like `8080` or `8000`, you can freely change the `SERVE_PORT` without needing elevated permissions.

3. **Save and exit**

4. **Restart the service to apply changes:**

```bash
sudo systemctl restart custom-http-server
```

---

### Verify the Port

You can check whether the server is now running on port 80:

```bash
sudo lsof -i :80
```

Or access it via:

```
http://<your-ip>/
```

---

Check service status to confirm it's running properly:

```bash
sudo systemctl status custom-http-server
```

## Logs

```bash
sudo journalctl -u custom-http-server -f
```

---

## Open Port 80 for Web Access

### On **Rocky Linux** (uses `firewalld`):

```bash
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload
```

**Verify the port is open:**

```bash
sudo firewall-cmd --list-ports
```

---

### On **Ubuntu** (typically uses `ufw`):

```bash
sudo ufw allow 80/tcp
sudo ufw reload
```

**Verify UFW status and rules:**

```bash
sudo ufw status
```

Or:

```bash
sudo ufw show
```

> **Note:** `firewalld` is not installed by default on Ubuntu. It usually uses `ufw` (Uncomplicated Firewall).

---

## Uninstall:
  To completely remove the HTTP server:
  ```bash
  cd custom-http-server/custom-http-server
  sudo ./uninstall.sh
  ```

---

## ✅ Final Notes
- Built entirely in **Python 3** (no external dependencies)
- Users can easily change the served directory in `/etc/custom-http-server.conf`.
- The Python file and config get copied to `/opt` and `/etc`, making the systemd unit generic.

---

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).  
You are free to use, modify, and distribute it with attribution.

## Author

Developed and maintained by [Muthukumar S]  
GitHub: [https://github.com/kumarmuthu/](https://github.com/kumarmuthu/)

---
