import os
import socket

from flask import Flask, jsonify
from flask_cors import CORS
from auth import auth_bp
from database import init_db

app = Flask(__name__)

_cors_origins = os.getenv("CORS_ORIGINS", "*").strip()
if _cors_origins == "*":
    CORS(app)
else:
    CORS(app, origins=[origin.strip() for origin in _cors_origins.split(",") if origin.strip()])

init_db()
app.register_blueprint(auth_bp)


@app.get("/health")
def health_check():
    return jsonify({"status": "ok"})


def _is_truthy(value):
    return str(value).strip().lower() in {"1", "true", "yes", "on"}


def _get_local_ips():
    ips = {"127.0.0.1"}
    try:
        hostname = socket.gethostname()
        for ip in socket.gethostbyname_ex(hostname)[2]:
            if ip and not ip.startswith("127."):
                ips.add(ip)
    except OSError:
        pass
    return sorted(ips)

if __name__ == "__main__":
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "5000"))
    debug = _is_truthy(os.getenv("FLASK_DEBUG", "0"))

    print(f"Starting backend on {host}:{port} (debug={debug})")
    for ip in _get_local_ips():
        print(f"  http://{ip}:{port}")

    app.run(host=host, port=port, debug=debug)
