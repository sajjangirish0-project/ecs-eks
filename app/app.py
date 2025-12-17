from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Container!',
        'hostname': socket.gethostname(),
        'platform': os.environ.get('PLATFORM', 'Unknown')
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)