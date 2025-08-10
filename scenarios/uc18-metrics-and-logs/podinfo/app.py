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
            max-width: 700px;
          }}
          .main-title {{
            font-size: 2.4em;
            font-weight: 700;
            letter-spacing: 1px;
            margin-top: 48px;
            margin-bottom: 38px;
            text-align: center;
            color: #0a2a49;
          }}
          .card-demo {{
            border-radius: 1.3rem;
            box-shadow: 0 2px 14px #007bff12;
            padding: 1.4rem 2.2rem 1.8rem 2.2rem;
            border: 1px solid #e0e8ef;
            background: #fff;
          }}
          .table-demo {{
            font-size: 1.07em;
            background: #fff;
            border-radius: 0.5em;
            overflow: hidden;
          }}
          .table-demo th {{
            background: #f2f7fa;
            font-weight: 500;
            color: #1c4366;
            border: none;
          }}
          .table-demo td {{
            vertical-align: middle;
            border: none;
            color: #344356;
            word-break: break-all;
          }}
          .table-demo tr:not(:last-child) td {{
            border-bottom: 1px solid #f0f1f3;
          }}
          .footer-link {{
            margin-top: 38px;
            text-align: center;
          }}
          @media (max-width: 600px) {{
            .main-title {{
              font-size: 2em;
            }}
            .card-demo {{
              padding: 1.2rem 0.4rem;
            }}
          }}
        </style>
      </head>
      <body>
        <div class="container py-3">
          <div class="main-title">Podinfo Demo <span style='font-size:1.05em;'>🚀</span></div>
          <div class="card-demo">
            <table class="table table-demo mb-0">
              <thead>
                <tr>
                  <th colspan="2" class="text-center fs-5"><span style="font-size:1.1em;">🧩</span> Pod &amp; Metrics Information</th>
                </tr>
              </thead>
              <tbody>
                <tr><td><b>Pod Name</b></td><td><code>{pod_name}</code></td></tr>
                <tr><td><b>Pod IP</b></td><td><code>{pod_ip}</code></td></tr>
                <tr><td><b>Namespace</b></td><td><code>{namespace}</code></td></tr>
                <tr><td><b>Service Account</b></td><td><code>{service_account}</code></td></tr>
                <tr><td><b>Container Start Time</b></td><td><code>{start_time}</code></td></tr>
                <tr><td><b>Service Account Token</b></td><td><code>{token_short}</code></td></tr>
                <tr><td><b>Memory Usage</b></td><td>{mem_info.rss / (1024*1024):.2f} <span class="text-secondary">MB</span></td></tr>
                <tr><td><b>CPU Usage</b></td><td>{cpu_percent} <span class="text-secondary">%</span></td></tr>
                <tr><td><b>Uptime</b></td><td>{uptime}</td></tr>
                <tr><td><b>Demo Page Requests</b></td><td><code>{DEMO_REQUESTS._value.get()}</code></td></tr>
                <tr><td><b>Random Metric</b></td><td><code>{RANDOM_METRIC._value.get():.2f}</code></td></tr>
                <tr><td><b>Last Request Time</b></td><td><code>{datetime.fromtimestamp(LAST_REQUEST_TS._value.get())}</code></td></tr>
              </tbody>
            </table>
          </div>
          <div class="footer-link">
            <a href="/metrics" target="_blank" class="btn btn-outline-primary btn-sm fw-semibold mt-3">
              Prometheus Metrics
            </a>
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
