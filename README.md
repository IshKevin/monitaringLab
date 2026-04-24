# Full Observability & Security Platform

## Project Overview

MonitoringLab is a **DevOps observability and security system** built on AWS using Infrastructure as Code (Terraform), containerization (Docker), and monitoring tools (Prometheus + Grafana).

It extends a Flask application with:

*  Metrics monitoring (Prometheus)
*  Visualization dashboards (Grafana)
*  Alerting system (Prometheus rules)
*  AWS logging (CloudWatch)
*  Security monitoring (CloudTrail + GuardDuty)
*  Infrastructure automation (Terraform)


#  Architecture

```text
Flask App (EC2 #1)
    ├── /metrics endpoint
    ├── Node Exporter
    └── Docker container

        ↓

Prometheus (EC2 #2)
    ├── Scrapes metrics from app
    └── Evaluates alert rules

        ↓

Grafana (EC2 #2)
    └── Dashboards (RPS, latency, errors)

AWS Services:
    ├── CloudWatch Logs
    ├── CloudTrail → S3 bucket
    └── GuardDuty (threat detection)
```


# Tech Stack

* Terraform (IaC)
* AWS EC2, S3, CloudTrail, GuardDuty
* Docker
* Flask (Python)
* Prometheus
* Grafana
* Node Exporter


# Project Structure

```text
monitoringLab/
├── app/
├── infra/
│   ├── modules/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── prometheus/
├── grafana/
├── cloudwatch/
├── reports/
├── monitoring/ # New directory for Docker Compose setup
└── README.md
```


# Prerequisites

Install:

* Terraform ≥ 1.5
* AWS CLI
* Docker
* Git

Configure AWS:

```bash
aws configure
```

---

#  Deployment Guide

## 1️⃣ Clone Repository

```bash
git clone <your-repo-url>
cd monitoringLab
```

---

## 2️⃣ Deploy Infrastructure (Terraform)

```bash
cd infra
terraform init
terraform apply
```

👉 Type `yes` when prompted

---

## 3️⃣ Get Outputs

After apply:

```bash
terraform output
```

You will get:

* App EC2 IP
* Monitoring EC2 IP

---

# 🖥️ 4. Setup Application Server (EC2 #1)

SSH into app server:

```bash
ssh -i app-server-key.pem ubuntu@<APP_IP>
```

Install Docker:

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo usermod -aG docker ubuntu
```

Run Flask App:

```bash
cd app
docker build -t flask-app .
docker run -d -p 5000:5000 flask-app
```

Run Node Exporter:

```bash
docker run -d -p 9100:9100 prom/node-exporter
```

---

# 📡 5. Setup Monitoring Server (EC2 #2)

SSH:

```bash
ssh -i monitoring-server-key.pem ubuntu@<MONITORING_IP>
```

Install Docker:

```bash
sudo apt update
sudo apt install -y docker.io
```

---

## Run Prometheus

Update `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: "flask-app"
    static_configs:
      - targets: ["<APP_IP>:5000"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["<APP_IP>:9100"]
```

Run Prometheus:

```bash
docker run -d \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

---

## Run Grafana

```bash
docker run -d -p 3000:3000 grafana/grafana
```

Access:

```text
http://<MONITORING_IP>:3000
```

Login:

* admin / admin

---

## Add Prometheus Data Source

URL:

```text
http://localhost:9090
```

---

## Import Dashboard

Use JSON from:

```text
grafana/dashboards/app-dashboard.json
```

---

# ☁️ 6. AWS Security Services

## CloudTrail

Automatically logs all AWS API activity to S3.

Bucket includes:

* Encryption (AES256)
* Lifecycle policy (30 days retention)

---

## GuardDuty

Enabled for threat detection:

* Malware detection
* Suspicious API activity
* Unauthorized access attempts

---

# 🚨 7. Alerts

Prometheus alert rule:

* Trigger when error rate > 5%

---

# 📊 8. Verification Steps

## App

```bash
curl http://<APP_IP>:5000
curl http://<APP_IP>:5000/metrics
```

---

## Prometheus

```text
http://<MONITORING_IP>:9090
```

Check:

* Targets = UP

---

## Grafana

```text
http://<MONITORING_IP>:3000
```

Check dashboards:

* Request rate
* Latency
* Error rate

---

# 🧪 9. Testing Alerts

Trigger error:

```bash
curl http://<APP_IP>:5000/error
```

---

# 🧹 10. Destroy Infrastructure

To avoid AWS charges:

```bash
cd infra
terraform destroy
```

---

# 📸 11. Deliverables

Include:

* Grafana dashboard screenshots
* Prometheus alert screenshots
* CloudWatch logs
* CloudTrail logs (S3)
* GuardDuty findings
* Terraform code
* 2-page report

---

# 🧠 Key Learning Outcomes

* Infrastructure as Code with Terraform
* Full observability pipeline
* Distributed monitoring system
* AWS security monitoring integration
* Containerized microservice monitoring


# 📸 12. Screenshots (MANDATORY FOR REPORT & SUBMISSION)


## 📁 Folder Structure for Evidence

Add this to your repo:

```text id="s8x3kp"
reports/
├── screenshots/
│   ├── grafana-dashboard.png
│   ├── prometheus-targets.png
│   ├── alert-firing.png
│   ├── app-metrics.png
│   ├── cloudwatch-logs.png
│   ├── cloudtrail-logs.png
│   └── guardduty-findings.png
└── report.pdf
```

---

## 📊 Required Screenshots

### 1️⃣ Grafana Dashboard

* RPS (Request Rate)
* Latency graph
* Error rate panel

📸 File:

```text id="g3wz9p"
grafana-dashboard.png
```

---

### 2️⃣ Prometheus Targets (Must show UP status)

📸 File:

```text id="x7k0la"
prometheus-targets.png
```

---

### 3️⃣ Alert Triggered (Error > 5%)

Run:

```bash id="a8d1pm"
curl http://<APP_IP>:5000/error
```

📸 File:

```text id="p9w2sd"
alert-firing.png
```

---

### 4️⃣ Application Metrics

Open:

```text id="m2k8zn"
http://<APP_IP>:5000/metrics
```

📸 File:

```text id="r4q0vz"
app-metrics.png
```

---

### 5️⃣ CloudWatch Logs

Show Docker logs streaming:

📸 File:

```text id="t6v1qk"
cloudwatch-logs.png
```

---

### 6️⃣ CloudTrail Logs (S3 Bucket)

Show AWS API activity logs stored in S3:

📸 File:

```text id="c8n2wx"
cloudtrail-logs.png
```

---

### 7️⃣ GuardDuty Findings

Show security detection results:

📸 File:

```text id="z0m7ra"
guardduty-findings.png
```

---

# 📄 13. Final Report (2-Page Requirement)

Create:

```text id="k1p9sd"
reports/report.pdf
```


# 🚀 Author

MonitoringLab Project — DevOps Observability & Security Stack
