"""
API Application Entry Point

This is a minimal starter. Adapt for your preferred framework:
- Flask: pip install flask
- FastAPI: pip install fastapi uvicorn
"""

import os
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

# Configuration
HOST = os.getenv('HOST', 'localhost')
PORT = int(os.getenv('PORT', 8000))


class APIHandler(BaseHTTPRequestHandler):
    """Simple HTTP request handler for API endpoints."""

    def _set_headers(self, status=200, content_type='application/json'):
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()

    def _json_response(self, data, status=200):
        self._set_headers(status)
        self.wfile.write(json.dumps(data).encode())

    def do_GET(self):
        """Handle GET requests."""
        if self.path == '/health':
            self._json_response({'status': 'healthy'})
        elif self.path == '/api/v1/items':
            self._json_response({'items': [], 'message': 'List items endpoint'})
        else:
            self._json_response({'error': 'Not found'}, 404)

    def do_POST(self):
        """Handle POST requests."""
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)

        if self.path == '/api/v1/items':
            self._json_response({'message': 'Item created', 'data': json.loads(body) if body else {}}, 201)
        else:
            self._json_response({'error': 'Not found'}, 404)


def main():
    """Start the API server."""
    server = HTTPServer((HOST, PORT), APIHandler)
    print(f"API server running at http://{HOST}:{PORT}")
    print("Endpoints:")
    print("  GET  /health")
    print("  GET  /api/v1/items")
    print("  POST /api/v1/items")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server...")
        server.shutdown()


if __name__ == '__main__':
    main()
