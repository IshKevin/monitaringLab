from flask import Flask, jsonify, request, g
from prometheus_client import Counter, Histogram, Gauge, generate_latest
import time

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "app_request_latency_seconds",
    "HTTP request latency in seconds",
    ["method", "endpoint"],
    buckets=[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0]
)

IN_PROGRESS = Gauge(
    "app_requests_in_progress",
    "Number of in-progress HTTP requests",
    ["endpoint"]
)


@app.before_request
def start_timer():
    g.start_time = time.time()
    if request.path != "/metrics":
        IN_PROGRESS.labels(endpoint=request.path).inc()


@app.after_request
def record_metrics(response):
    if request.path != "/metrics":
        latency = time.time() - g.start_time
        REQUEST_LATENCY.labels(
            method=request.method, endpoint=request.path
        ).observe(latency)
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.path,
            status=str(response.status_code)
        ).inc()
        IN_PROGRESS.labels(endpoint=request.path).dec()
    return response


@app.route("/")
def home():
    return jsonify({"message": "Monitoring App Running"})


@app.route("/slow")
def slow():
    time.sleep(1.2)
    return jsonify({"message": "Slow response"})


@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": "text/plain"}


@app.route("/error")
def error():
    return jsonify({"error": "An error occurred"}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
