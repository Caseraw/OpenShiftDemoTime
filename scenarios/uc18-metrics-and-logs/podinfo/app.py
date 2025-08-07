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

@app.before_first_request
def activate_periodic_logger():
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
    <h2>Pod Information</h2>
    <ul>
        <li><b>Pod Name:</b> {pod_name}</li>
        <li><b>Pod IP:</b> {pod_ip}</li>
        <li><b>Namespace:</b> {namespace}</li>
        <li><b>Service Account:</b> {service_account}</li>
        <li><b>Container Start Time:</b> {start_time}</li>
        <li><b>Service Account Token:</b> {token_short}</li>
    </ul>
    <h2>System Metrics</h2>
    <ul>
        <li><b>Memory Usage:</b> {mem_info.rss / (1024*1024):.2f} MB</li>
        <li><b>CPU Usage:</b> {cpu_percent} %</li>
        <li><b>Uptime:</b> {uptime}</li>
    </ul>
    <h2>Custom Metrics</h2>
    <ul>
        <li><b>Demo page requests:</b> {DEMO_REQUESTS._value.get()}</li>
        <li><b>Random metric:</b> {RANDOM_METRIC._value.get():.2f}</li>
        <li><b>Last request time:</b> {datetime.fromtimestamp(LAST_REQUEST_TS._value.get())}</li>
    </ul>
    <a href="/metrics">Prometheus Metrics Endpoint</a>
    """

@app.route("/metrics")
def metrics():
    update_metrics()
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
