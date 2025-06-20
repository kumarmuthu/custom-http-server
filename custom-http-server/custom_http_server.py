#!/usr/bin/env python3

__version__ = "2025.05.25.01"
__author__ = "Muthukumar Subramanian"

'''
Custom HTTP Server Service

A lightweight Python-based HTTP file server with MIME support.
This systemd-enabled service allows users to serve files from a configurable directory and port.
Configuration is managed through an environment file, making it flexible for deployment across different systems.

2025.05.25.01 - Initial Draft
2025.06.21.01 - Added MIME types and Max OS support
'''

import os
import sys
import mimetypes
from http.server import SimpleHTTPRequestHandler, HTTPServer

# Custom MIME types
# Text formats
mimetypes.add_type('text/plain', '.log')
mimetypes.add_type('text/plain', '.txt')
mimetypes.add_type('text/plain', '.tap')
mimetypes.add_type('text/plain', '.md')
mimetypes.add_type('text/plain', '.conf')
mimetypes.add_type('text/plain', '.ini')
mimetypes.add_type('text/plain', '.env')
mimetypes.add_type('text/plain', '')  # Extensionless

# Code & markup
mimetypes.add_type('text/html', '.html')
mimetypes.add_type('application/xml', '.xml')
mimetypes.add_type('application/json', '.json')
mimetypes.add_type('application/javascript', '.js')
mimetypes.add_type('text/css', '.css')
mimetypes.add_type('text/x-python', '.py')
mimetypes.add_type('text/x-shellscript', '.sh')

# Images
mimetypes.add_type('image/png', '.png')
mimetypes.add_type('image/jpeg', '.jpg')
mimetypes.add_type('image/jpeg', '.jpeg')
mimetypes.add_type('image/gif', '.gif')
mimetypes.add_type('image/svg+xml', '.svg')
mimetypes.add_type('image/webp', '.webp')
mimetypes.add_type('image/x-icon', '.ico')

# Docs
mimetypes.add_type('application/pdf', '.pdf')
mimetypes.add_type('application/msword', '.doc')
mimetypes.add_type('application/vnd.openxmlformats-officedocument.wordprocessingml.document', '.docx')
mimetypes.add_type('application/vnd.ms-excel', '.xls')
mimetypes.add_type('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', '.xlsx')
mimetypes.add_type('application/vnd.ms-powerpoint', '.ppt')
mimetypes.add_type('application/vnd.openxmlformats-officedocument.presentationml.presentation', '.pptx')

# Archives
mimetypes.add_type('application/zip', '.zip')
mimetypes.add_type('application/x-tar', '.tar')
mimetypes.add_type('application/gzip', '.gz')
mimetypes.add_type('application/x-bzip2', '.bz2')
mimetypes.add_type('application/x-7z-compressed', '.7z')


class CustomHandler(SimpleHTTPRequestHandler):
    def guess_type(self, path):
        base, ext = os.path.splitext(path)
        return mimetypes.types_map.get(ext, 'application/octet-stream') if ext else 'text/plain'

    def end_headers(self):
        if self.path.endswith(('.log', '.txt', '.tap', '.xml', '.md', '.html', '.json',
                               '.css', '.js', '.pdf', '.cfg', '.ini', '.conf', '.env', '.sh', '.py')):
            self.send_header('Content-Disposition', 'inline')

        super().end_headers()


if __name__ == '__main__':
    import os
    import platform
    import getpass
    import argparse

    print("{:#^30}".format("Script Start"))
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('--path', default=None, help='Directory to serve')
        parser.add_argument('--port', type=int, default=80, help='Port number')
        args = parser.parse_args()

        if platform.system() == "Windows":
            user_home = os.path.expanduser("~")
        else:
            import pwd

            actual_user = os.environ.get("SUDO_USER") or getpass.getuser()
            user = actual_user or os.getlogin()
            user_home = pwd.getpwnam(user).pw_dir

        # Fallback if path not passed
        serve_path = args.path or user_home
        print(f"Resolved serve path:{args.path} {serve_path}")

        try:
            # Expand and validate
            serve_path = os.path.expanduser(serve_path)
        except Exception as ValidateErr:
            raise ValueError(f"Invalid path: {serve_path}")

        if not os.path.isdir(serve_path):
            raise ValueError(f"Invalid directory: {serve_path}")

        os.chdir(serve_path)

        server_address = ('0.0.0.0', args.port)
        httpd = HTTPServer(server_address, CustomHandler)
        print(f"Serving {args.path} on port {args.port}...")
        httpd.serve_forever()
    except Exception as Err:
        print(f"Observed exception is: {Err}")
    print("{:#^30}".format("Script End"))
