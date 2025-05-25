#!/usr/bin/env python3

__version__ = "2025.05.25.01"
__author__ = "Muthukumar Subramanian"

'''
Custom HTTP Server Service

A lightweight Python-based HTTP file server with MIME support.
This systemd-enabled service allows users to serve files from a configurable directory and port.
Configuration is managed through an environment file, making it flexible for deployment across different systems.
'''

import os
import sys
import mimetypes
from http.server import SimpleHTTPRequestHandler, HTTPServer
import argparse

# Custom MIME types
mimetypes.add_type('text/plain', '.log')
mimetypes.add_type('text/plain', '.txt')
mimetypes.add_type('text/plain', '.tap')
mimetypes.add_type('application/xml', '.xml')
mimetypes.add_type('text/html', '.html')
mimetypes.add_type('text/plain', '')  # Default for extensionless files


class CustomHandler(SimpleHTTPRequestHandler):
    def guess_type(self, path):
        base, ext = os.path.splitext(path)
        return mimetypes.types_map.get(ext, 'application/octet-stream') if ext else 'text/plain'

    def end_headers(self):
        if self.path.endswith(('.log', '.txt', '.tap', '.xml')):
            self.send_header('Content-Disposition', 'inline')

        super().end_headers()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--path', default='/root', help='Directory to serve')
    parser.add_argument('--port', type=int, default=80, help='Port number')
    args = parser.parse_args()

    os.chdir(os.path.expanduser(args.path))
    server_address = ('0.0.0.0', args.port)
    httpd = HTTPServer(server_address, CustomHandler)
    print(f"Serving {args.path} on port {args.port}...")
    httpd.serve_forever()
