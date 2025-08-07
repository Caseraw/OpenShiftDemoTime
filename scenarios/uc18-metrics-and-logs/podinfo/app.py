import os
import random
import time
import threading
import logging
from flask import Flask, Response, request
from datetime import datetime
from prometheus_client import Counter, Gauge, generate_latest, CONTENT_TYPE_LATEST
import psutil

app = Flask(__name__)

# --- Logging setup ---
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

# --- Metrics ---
START_TIME = datetime.now()
APP_UPTIME = Gauge("app_uptime_seconds", "App uptime in seconds")
HTTP_REQUESTS = Counter("http_requests_total", "Total HTTP requests handled", ["method", "endpoint"])
DEMO_REQUESTS = Counter("demo_requests_total", "Demo (/) page requests")
RANDOM_METRIC = Gauge("demo_random_metric", "Random gauge metric for demonstration")
APP_START_TIMESTAMP = Gauge("app_start_time_seconds", "App start time as Unix timestamp")
LAST_REQUEST_TS = Gauge("demo_last_request_timestamp", "Unix timestamp of last / hit")
APP_START_TIMESTAMP.set(START_TIME.timestamp())

def read_file(path):
    try:
        with open(path, 'r') as f:
            return f.read().strip()
    except Exception:
        return 'Unavailable'

def get_pod_info():
    pod_name = os.environ.get("HOSTNAME", "Unknown")
    pod_ip = os.environ.get("POD_IP", "Unknown")
    namespace = read_file("/var/run/secrets/kubernetes.io/serviceaccount/namespace")
    service_account = os.environ.get("SERVICE_ACCOUNT", "Unknown")
    start_time = datetime.fromtimestamp(os.stat('/proc/1').st_ctime)
    token = read_file("/var/run/secrets/kubernetes.io/serviceaccount/token")
    token_short = token[:16] + '...' if token != 'Unavailable' else token
    return pod_name, pod_ip, namespace, service_account, start_time, token_short

def get_system_metrics():
    process = psutil.Process(os.getpid())
    mem_info = process.memory_info()
    cpu_percent = process.cpu_percent(interval=0.05)
    uptime = datetime.now() - datetime.fromtimestamp(process.create_time())
    return mem_info, cpu_percent, uptime

def update_metrics():
    uptime = (datetime.now() - START_TIME).total_seconds()
    APP_UPTIME.set(uptime)
    RANDOM_METRIC.set(random.uniform(0, 100))

def periodic_logger():
    while True:
        pod_name, pod_ip, namespace, service_account, start_time, token_short = get_pod_info()
        mem_info, cpu_percent, uptime = get_system_metrics()
        logging.info(
            f"[PERIODIC] PodInfo: pod_name={pod_name}, pod_ip={pod_ip}, ns={namespace}, sa={service_account}, "
            f"start_time={start_time}, token={token_short} | "
            f"Metrics: mem={mem_info.rss / (1024*1024):.2f}MB, cpu={cpu_percent:.1f}%, uptime={uptime}"
        )
        time.sleep(2)

# --- Start the periodic logger as a background thread immediately (Flask 3.x safe) ---
t = threading.Thread(target=periodic_logger, daemon=True)
t.start()

@app.route("/")
def index():
    HTTP_REQUESTS.labels(method=request.method, endpoint="/").inc()
    DEMO_REQUESTS.inc()
    now = datetime.now()
    LAST_REQUEST_TS.set(now.timestamp())
    update_metrics()

    pod_name, pod_ip, namespace, service_account, start_time, token_short = get_pod_info()
    mem_info, cpu_percent, uptime = get_system_metrics()

    # Log each page visit
    logging.info(
        f"[REQUEST] / visited: pod_name={pod_name}, pod_ip={pod_ip}, ns={namespace}, sa={service_account}, "
        f"start_time={start_time}, token={token_short} | "
        f"mem={mem_info.rss / (1024*1024):.2f}MB, cpu={cpu_percent:.1f}%, uptime={uptime}"
    )

    return f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Podinfo Demo App</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body {{
                background: linear-gradient(120deg, #e9f2fa 0%, #f7faff 100%);
                min-height: 100vh;
            }}
            .main-title {{
                font-size: 2.6em;
                font-weight: 700;
                letter-spacing: 1px;
                margin: 38px 0 12px 0;
                text-align: center;
                color: #0a2a49;
                background: linear-gradient(90deg, #0a2a49, #00b8d9 70%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }}
            .subtitle {{
                text-align: center;
                color: #0077b6;
                margin-bottom: 38px;
                font-size: 1.1em;
                font-weight: 400;
                letter-spacing: 0.4px;
            }}
            .section-card {{
                background: #fff;
                border-radius: 22px;
                box-shadow: 0 2px 18px #0052cc0a;
                padding: 34px 36px 16px 36px;
                margin-bottom: 30px;
                max-width: 520px;
                margin-left: auto;
                margin-right: auto;
            }}
            .section-title {{
                font-size: 1.22em;
                font-weight: 500;
                color: #0069c0;
                margin-bottom: 18px;
                display: flex;
                align-items: center;
                gap: 0.7em;
            }}
            .metric-list {{
                padding-left: 0;
                list-style: none;
            }}
            .metric-list li {{
                font-size: 1.09em;
                margin-bottom: 0.7em;
                color: #313d4d;
            }}
            .metric-list code {{
                font-size: 1em;
                background: #eef6fc;
                border-radius: 4px;
                padding: 1px 7px;
                color: #1565c0;
            }}
            .btn-metrics {{
                background: linear-gradient(90deg,#0052cc,#00b8d9);
                color: #fff;
                font-weight: 500;
                border-radius: 1.4em;
                padding: 0.48em 1.9em;
                border: none;
                transition: 0.2s;
                margin-top: 8px;
                margin-bottom: 6px;
            }}
            .btn-metrics:hover {{
                background: linear-gradient(90deg,#00b8d9,#0052cc);
                color: #fff;
            }}
        </style>
    </head>
    <body>
        <div class="main-title">Podinfo Demo <span style='font-size:1.12em;'>🚀</span></div>
        <div class="subtitle">OpenShift &amp; Kubernetes | Metrics &amp; Logs</div>
        <div class="section-card">
            <div class="section-title">🧩 Pod Information</div>
            <ul class="metric-list">
                <li><b>Pod Name:</b> <code>{pod_name}</code></li>
                <li><b>Pod IP:</b> <code>{pod_ip}</code></li>
                <li><b>Namespace:</b> <code>{namespace}</code></li>
                <li><b>Service Account:</b> <code>{service_account}</code></li>
                <li><b>Container Start Time:</b> <code>{start_time}</code></li>
                <li><b>Service Account Token:</b> <code>{token_short}</code></li>
            </ul>
        </div>
        <div class="section-card">
            <div class="section-title">💻 System Metrics</div>
            <ul class="metric-list">
                <li><b>Memory Usage:</b> {mem_info.rss / (1024*1024):.2f} <span style="color:#91b4cc;">MB</span></li>
                <li><b>CPU Usage:</b> {cpu_percent} <span style="color:#91b4cc;">%</span></li>
                <li><b>Uptime:</b> {uptime}</li>
            </ul>
        </div>
        <div class="section-card">
            <div class="section-title">📊 Custom Metrics</div>
            <ul class="metric-list">
                <li><b>Demo page requests:</b> <code>{DEMO_REQUESTS._value.get()}</code></li>
                <li><b>Random metric:</b> <code>{RANDOM_METRIC._value.get():.2f}</code></li>
                <li><b>Last request time:</b> <code>{datetime.fromtimestamp(LAST_REQUEST_TS._value.get())}</code></li>
            </ul>
            <a class="btn btn-metrics" href="/metrics" target="_blank">View Prometheus Metrics</a>
        </div>
    </body>
    </html>
    """

@app.route("/metrics")
def metrics():
    update_metrics()
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
