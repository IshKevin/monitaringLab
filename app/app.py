from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, generate_latest
import time

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total Requests",
    ["status"]
)

REQUEST_LATENCY = Histogram("app_request_latency_seconds", "Request latency")


@app.route("/")
def home():
    REQUEST_COUNT.labels(status="200").inc()
    return jsonify({"message": "Monitoring App Running"})


@app.route("/slow")
def slow():
    start = time.time()
    time.sleep(1.2)
    REQUEST_LATENCY.observe(time.time() - start)
    return "slow response"


@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": "text/plain"}


@app.route("/error")
def error():
    REQUEST_COUNT.labels(status="500").inc()
    return "error occurred", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)