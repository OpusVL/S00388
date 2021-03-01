#!/usr/bin/env python3

import sys
from http.server import HTTPServer, BaseHTTPRequestHandler

class Redirect(BaseHTTPRequestHandler):
   def do_GET(self):
        self.path = '/var/www/html/index.html'
        file_to_open = open(self.path).read()

        self.send_response(302)
        
        self.end_headers()
        self.wfile.write(bytes(file_to_open, 'utf-8'))

HTTPServer(("", 8080), Redirect).serve_forever()
