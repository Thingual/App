#!/usr/bin/env python
"""Legacy HTTP proxy server using FastAPI TestClient (kept for reference)."""

from __future__ import annotations

import json
import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

os.environ["PYTHONIOENCODING"] = "utf-8"

BACKEND_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BACKEND_ROOT))

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


class ProxyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            response = client.get(self.path)
            self.send_response(response.status_code)
            for key, value in response.headers.items():
                if key.lower() not in ["content-encoding"]:
                    self.send_header(key, value)
            self.end_headers()
            self.wfile.write(response.content)
        except Exception as e:
            self.send_error(500, str(e))

    def do_POST(self):
        try:
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length) if content_length > 0 else b""

            request_headers = {}
            for key, value in self.headers.items():
                if key.lower() not in ["host", "connection", "content-length"]:
                    request_headers[key] = value

            response = client.post(self.path, content=body, headers=request_headers)

            self.send_response(response.status_code)
            for key, value in response.headers.items():
                if key.lower() not in ["content-encoding"]:
                    self.send_header(key, value)
            self.end_headers()
            self.wfile.write(response.content)
        except Exception as e:
            self.send_error(500, str(e))

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def log_message(self, format, *args):
        return


def main() -> int:
    try:
        server = HTTPServer(("0.0.0.0", 8002), ProxyHandler)
        print("Starting legacy proxy server on http://0.0.0.0:8002...")
        server.serve_forever()
        return 0
    except KeyboardInterrupt:
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
