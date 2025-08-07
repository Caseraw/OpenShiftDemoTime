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
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Podinfo Demo</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
          body {{
            background: #f8fafc;
          }}
          .container {{
            max-width: 900px;
          }}
          .top-bar {{
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 40px;
            margin-bottom: 30px;
          }}
          .main-title {{
            font-size: 2.2em;
            font-weight: 700;
            letter-spacing: 1px;
            margin-bottom: 0.25em;
          }}
          .subtitle {{
            font-size: 1.1em;
            color: #6c757d;
            margin-bottom: 0.5em;
            font-weight: 400;
            letter-spacing: 0.4px;
          }}
          .metric-card {{
            border-radius: 1.25rem;
            box-shadow: 0 2px 12px #007bff0e;
            margin-bottom: 2rem;
            padding: 2.4rem 2.1rem 1.2rem 2.1rem;
            border: 1px solid #e0e8ef;
            background: #fff;
          }}
          .metric-card h4 {{
            font-size: 1.19em;
            margin-bottom: 1em;
            font-weight: 500;
            color: #2064bc;
            letter-spacing: 0.04em;
          }}
          .metric-list {{
            padding-left: 0;
            list-style: none;
          }}
          .metric-list li {{
            font-size: 1.06em;
            margin-bottom: 0.68em;
            color: #374151;
          }}
          .metric-list code {{
            font-size: 1em;
            background: #f4f8ff;
            border-radius: 4px;
            padding: 1px 7px;
            color: #0052cc;
          }}
        </style>
      </head>
      <body>
        <div class="container py-3">
          <div class="top-bar">
            <div>
              <div class="main-title">Podinfo Demo <span style='font-size:1.05em;'>🚀</span></div>
              <div class="subtitle">OpenShift &amp; Kubernetes · Metrics &amp; Logs</div>
            </div>
            <div>
              <a href="/metrics" target="_blank" class="btn btn-outline-primary btn-sm fw-semibold">Prometheus Metrics</a>
            </div>
          </div>
          <div class="row g-4">
            <div class="col-md-4">
              <div class="metric-card h-100">
                <h4>🧩 Pod Information</h4>
                <ul class="metric-list">
                  <li><b>Pod Name:</b> <code>{pod_name}</code></li>
                  <li><b>Pod IP:</b> <code>{pod_ip}</code></li>
                  <li><b>Namespace:</b> <code>{namespace}</code></li>
                  <li><b>Service Account:</b> <code>{service_account}</code></li>
                  <li><b>Container Start Time:</b> <code>{start_time}</code></li>
                  <li><b>SA Token:</b> <code>{token_short}</code></li>
                </ul>
              </div>
            </div>
            <div class="col-md-4">
              <div class="metric-card h-100">
                <h4>💻 System Metrics</h4>
                <ul class="metric-list">
                  <li><b>Memory Usage:</b> {mem_info.rss / (1024*1024):.2f} <span style="color:#9db2c8;">MB</span></li>
                  <li><b>CPU Usage:</b> {cpu_percent} <span style="color:#9db2c8;">%</span></li>
                  <li><b>Uptime:</b> {uptime}</li>
                </ul>
              </div>
            </div>
            <div class="col-md-4">
              <div class="metric-card h-100">
                <h4>📊 Custom Metrics</h4>
                <ul class="metric-list">
                  <li><b>Demo page requests:</b> <code>{DEMO_REQUESTS._value.get()}</code></li>
                  <li><b>Random metric:</b> <code>{RANDOM_METRIC._value.get():.2f}</code></li>
                  <li><b>Last request:</b> <code>{datetime.fromtimestamp(LAST_REQUEST_TS._value.get())}</code></li>
                </ul>
              </div>
            </div>
          </div>
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
