# MonitoringLab

A full-stack observability and security platform built with Flask, Prometheus, Grafana, and AWS infrastructure managed via Terraform.

## Table of Contents

- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Services & Ports](#services--ports)
- [Configuration](#configuration)
- [Local Development](#local-development)
- [AWS Deployment](#aws-deployment)
- [Monitoring & Dashboards](#monitoring--dashboards)
- [Alerting](#alerting)
- [CI/CD](#cicd)
- [AWS Security](#aws-security)
- [Testing](#testing)

---

## Quick Start

**Prerequisites:** Docker, Docker Compose

```bash
git clone <your-repo-url>
cd monitoringLab
docker compose up --build
```

| Service    | URL                     | Credentials    |
|------------|-------------------------|----------------|
| Flask App  | http://localhost:5000   | —              |
| Prometheus | http://localhost:9090   | —              |
| Grafana    | http://localhost:3000   | admin / admin  |

Dashboards are provisioned automatically on first start.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Docker Network                       │
│                                                         │
│  ┌─────────────┐    scrape     ┌──────────────────────┐ │
│  │  Flask App  │ ◄─────────── │      Prometheus       │ │
│  │  :5000      │              │      :9090            │ │
│  └─────────────┘              └──────────┬───────────┘ │
│                                          │ datasource   │
│  ┌─────────────┐    scrape     ┌──────────▼───────────┐ │
│  │Node Exporter│ ◄─────────── │       Grafana         │ │
│  │  :9100      │              │       :3000           │ │
│  └─────────────┘              └──────────────────────┘ │
└─────────────────────────────────────────────────────────┘

AWS (production):
  EC2 #1 (App)        → Flask App + Node Exporter
  EC2 #2 (Monitoring) → Prometheus + Grafana
  S3                  → CloudTrail audit logs
  CloudTrail          → AWS API activity logging
  GuardDuty           → Threat detection
```

---

## Project Structure

```
monitoringLab/
├── app/
│   ├── app.py              # Flask application with Prometheus metrics
│   ├── test_app.py         # Unit tests
│   ├── requirements.txt
│   └── Dockerfile
├── prometheus/
│   ├── prometheus.yml      # Scrape config (uses Docker service names)
│   ├── alert_rules.yml     # Alerting rules
│   └── docker-compose.yml  # Alternative compose (run from prometheus/)
├── grafana/
│   ├── dashboards/
│   │   ├── app-dashboard.json     # Application metrics dashboard
│   │   └── system-dashboard.json  # System metrics dashboard
│   └── provisioning/
│       ├── datasources.yml        # Prometheus datasource config
│       └── dashboards/
│           └── default.yml        # Dashboard provisioner config
├── infra/                  # Terraform (AWS EC2, S3, CloudTrail)
├── cloudwatch/             # CloudWatch Logs config
├── node-exporter/          # Standalone Node Exporter compose
├── docker-compose.yml      # Main compose — starts all services
├── Jenkinsfile             # CI/CD pipeline
└── README.md
```

---

## Services & Ports

| Service       | Port | Description                          |
|---------------|------|--------------------------------------|
| Flask App     | 5000 | Application with `/metrics` endpoint |
| Node Exporter | 9100 | Host system metrics                  |
| Prometheus    | 9090 | Metrics storage & querying           |
| Grafana       | 3000 | Dashboards & visualization           |

### App Endpoints

| Endpoint   | Description                               |
|------------|-------------------------------------------|
| `GET /`    | Health check — returns `{"message": ...}` |
| `GET /slow`| Simulates 1.2s latency for testing        |
| `GET /error`| Returns 500 for alert testing            |
| `GET /metrics`| Prometheus metrics exposition          |

---

## Configuration

### Prometheus Targets (`prometheus/prometheus.yml`)

The scrape targets use Docker service names by default. For AWS deployment, replace with the app server IP:

```yaml
scrape_configs:
  - job_name: "flask-app"
    static_configs:
      - targets: ["<APP_IP>:5000"]   # Docker: app:5000

  - job_name: "node-exporter"
    static_configs:
      - targets: ["<APP_IP>:9100"]   # Docker: node-exporter:9100
```

### Grafana

Credentials are set via environment variables in `docker-compose.yml`:

```yaml
environment:
  - GF_SECURITY_ADMIN_USER=admin
  - GF_SECURITY_ADMIN_PASSWORD=admin
```

Datasource and dashboards are auto-provisioned from `grafana/provisioning/`.

---

## Local Development

### Run with Docker Compose (recommended)

```bash
# Start everything
docker compose up --build

# Run in background
docker compose up --build -d

# View logs
docker compose logs -f

# Stop
docker compose down
```

### Run Flask app directly

```bash
cd app
pip install -r requirements.txt
python app.py
```

### Run tests

```bash
cd app
pip install pytest
pytest test_app.py -v
```

---

## AWS Deployment

### 1. Prerequisites

```bash
# Install tools
terraform >= 1.5
aws-cli
docker

# Configure AWS credentials
aws configure
```

### 2. Deploy Infrastructure

```bash
cd infra
terraform init
terraform apply
```

Note the output IPs:

```bash
terraform output
# app_server_ip      = "x.x.x.x"
# monitoring_server_ip = "x.x.x.x"
```

### 3. Set up App Server (EC2 #1)

```bash
ssh -i infra/app-server-key.pem ubuntu@<APP_IP>

# Install Docker
sudo apt update && sudo apt install -y docker.io
sudo systemctl start docker && sudo usermod -aG docker ubuntu
newgrp docker

# Start Flask app + Node Exporter
docker run -d -p 5000:5000 <your-dockerhub-user>/flask-app
docker run -d -p 9100:9100 prom/node-exporter
```

### 4. Set up Monitoring Server (EC2 #2)

```bash
ssh -i infra/monitoring-server-key.pem ubuntu@<MONITORING_IP>

sudo apt update && sudo apt install -y docker.io docker-compose-plugin
sudo systemctl start docker && sudo usermod -aG docker ubuntu
newgrp docker
```

Clone and configure:

```bash
git clone <your-repo-url>
cd monitoringLab

# Set the app IP in prometheus config
sed -i 's/app:5000/<APP_IP>:5000/g' prometheus/prometheus.yml
sed -i 's/node-exporter:9100/<APP_IP>:9100/g' prometheus/prometheus.yml

# Start monitoring stack
docker compose up -d prometheus grafana
```

---

## Monitoring & Dashboards

Grafana at `http://<MONITORING_IP>:3000` (login: admin / admin) auto-loads two dashboards:

### Application Monitoring Dashboard

| Panel                     | Metric                                          |
|---------------------------|-------------------------------------------------|
| Total Requests            | `sum(app_requests_total)`                       |
| Request Rate              | `sum(rate(app_requests_total[2m]))`             |
| Error Rate                | 500 responses / total × 100                    |
| P95 Latency               | `histogram_quantile(0.95, ...)`                 |
| Request Rate by Endpoint  | Per-endpoint req/s timeseries                   |
| Request Rate by Status    | HTTP 200 / 500 breakdown                        |
| Latency Percentiles       | P50 / P95 / P99 in ms                           |
| Average Latency           | Per-endpoint mean latency                       |
| Error Rate Over Time      | Time series with 1%/5% threshold lines         |
| Success Rate Gauge        | Live percentage gauge (green ≥95%)             |
| In-Progress Requests      | Active in-flight requests per endpoint          |

### System Metrics Dashboard

| Panel                  | Metric                                               |
|------------------------|------------------------------------------------------|
| CPU Usage stat         | Idle-subtracted CPU %                                |
| Memory Usage stat      | `1 - MemAvailable/MemTotal`                          |
| Disk Usage stat        | Filesystem used %                                    |
| System Uptime          | `node_time - node_boot_time`                         |
| CPU % over time        | Per-instance timeseries with 70%/90% thresholds     |
| CPU by Mode (stacked)  | user / system / iowait / softirq breakdown           |
| Memory Breakdown       | Used / Available / Cache+Buffers bytes               |
| Memory Gauge           | Live % gauge (green ≤70%)                            |
| Disk I/O Throughput    | Read/write bytes/s per device                        |
| Disk IOPS              | Read/write ops/s per device                          |
| Network Throughput     | Rx/Tx bytes/s per interface                          |
| Network Errors & Drops | Receive/transmit errors and drops                    |
| Load Average           | 1m / 5m / 15m system load                           |
| Node Exporter Health   | UP / DOWN status indicator                           |

---

## Alerting

Defined in `prometheus/alert_rules.yml`:

| Alert          | Condition                    | Severity |
|----------------|------------------------------|----------|
| HighErrorRate  | Error rate > 5% for 1 minute | critical |

Test the alert:

```bash
# Trigger 500 errors
for i in $(seq 1 20); do curl http://localhost:5000/error; done

# Check firing alerts
open http://localhost:9090/alerts
```

---

## CI/CD

`Jenkinsfile` defines a pipeline with stages:

1. **Checkout** — clone repository
2. **Install Dependencies** — `pip install -r requirements.txt`
3. **Run Tests** — `pytest test_app.py`
4. **Build Docker Image** — `docker build`
5. **Push to Docker Hub** — push image to registry
6. **Deploy to EC2** — SSH and restart container

---

## AWS Security

### CloudTrail

All AWS API activity is logged to S3 with:
- AES256 encryption
- 30-day retention lifecycle policy
- Multi-region coverage

### GuardDuty

Threat detection for:
- Unauthorized access attempts
- Suspicious API calls
- Malware detection

_(Enable by uncommenting `infra/guardduty.tf`)_

### CloudWatch Logs

Docker container logs streamed to CloudWatch via the `awslogs` driver. Configure with `cloudwatch/docker-logging.json`.

---

## Testing

```bash
cd app
pytest test_app.py -v
```

| Test                                      | Validates                              |
|-------------------------------------------|----------------------------------------|
| `test_home_endpoint`                      | Returns 200 + correct JSON             |
| `test_error_endpoint`                     | Returns 500 + JSON error body          |
| `test_slow_endpoint`                      | Returns 200 after delay                |
| `test_metrics_endpoint_includes_prometheus_metrics` | Metrics contain expected counter names |
