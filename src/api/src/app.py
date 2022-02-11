import os
import psutil
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/stats')
def stats():
    cpu = psutil.cpu_percent()
    ram = psutil.virtual_memory().percent
    pod = os.environ.get("K8S_POD_NAME", None)
    node = os.environ.get("K8S_NODE_NAME", None)
    namespace = os.environ.get("K8S_POD_NAMESPACE", None)
    return jsonify({"ram": ram, "cpu": cpu, "pod": pod, "namespace": namespace, "node": node })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
