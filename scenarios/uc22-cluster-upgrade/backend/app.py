from flask import Flask, jsonify
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/api/status')
def status():
    return jsonify({
        "datetime": datetime.now().isoformat(),
        "pod_name": os.environ.get("MY_POD_NAME", "unknown"),
        "node_name": os.environ.get("MY_NODE_NAME", "unknown")
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
