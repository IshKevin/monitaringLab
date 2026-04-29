# Full Observability & Security Solution

A production-style **observability and security platform** built using Flask, Prometheus, Grafana, and AWS infrastructure provisioned with Terraform.

This project demonstrates how to design, deploy, and operate a **full-stack monitoring system** for modern applications, covering metrics, alerting, logging, and cloud security.


# Overview

MonitoringLab simulates a real-world system where:

* A **Flask application** exposes metrics
* **Prometheus** collects and stores time-series data
* **Grafana** visualizes system and application health
* **Node Exporter** provides infrastructure metrics
* **AWS services** ensure security, logging, and auditability

The entire system runs:

* Locally via Docker (single EC2 equivalent)
* In production across AWS EC2 instances


# Architecture

Below is the system architecture showing how all components interact.

![Architecture Diagram](/assets/architecture.png)

### Flow Explanation

* User sends request → Flask App
* Flask App exposes `/metrics`
* Prometheus scrapes metrics from Flask + Node Exporter
* Grafana queries Prometheus for visualization

---

# Core Components

## 1. Flask Application

A lightweight API that simulates real workloads and exposes Prometheus metrics.

![Flask Application](/assets/flask-app.png)

### Endpoints

* `/` → health check
* `/slow` → simulates latency
* `/error` → generates HTTP 500 errors
* `/metrics` → Prometheus metrics endpoint

---

## 2. Prometheus (Metrics Collection)

Prometheus is responsible for scraping and storing time-series metrics.

![Prometheus UI](/assets/prometheus.png)

### Key Responsibilities

* Scrapes Flask application metrics
* Scrapes Node Exporter system metrics
* Evaluates alerting rules
* Stores time-series data

---

## 3. Grafana (Visualization Layer)

Grafana provides dashboards for system observability.

### Application Dashboard

Shows:

* Request rate
* Error rate
* Latency (P95, P99)

![Grafana App Dashboard](/assets/grafana-app-dashboard.png)

### System Dashboard

Shows:

* CPU usage
* Memory usage
* Disk usage
* Network traffic

![Grafana System Dashboard](/assets/grafana-system-dashboard.png)

---

## 4. Node Exporter (System Metrics)

Node Exporter exposes host-level metrics.

![Node Exporter Metrics](/assets/node-exporter.png)

### Metrics Include

* CPU utilization
* Memory usage
* Disk I/O
* Network traffic

---

## 5. AWS Infrastructure (Terraform)

Infrastructure is provisioned using Terraform.

![AWS Infrastructure](/assets/aws-infra.png)

### Resources

* EC2 (Application server)
* EC2 (Monitoring server)
* S3 (CloudTrail logs)
* CloudTrail (API auditing)
* GuardDuty (threat detection)

# Local Development

Run full stack locally using Docker Compose:

```
docker compose up --build
```

Access services:

* Flask → [http://localhost:5000](http://localhost:5000)
* Prometheus → [http://localhost:9090](http://localhost:9090)
* Grafana → [http://localhost:3000](http://localhost:3000)

---

# AWS Deployment

## Step 1: Provision Infrastructure

```
cd infra
terraform init
terraform apply
```

## Step 2: Application Server (EC2 #1)

* Flask App runs on port 5000
* Node Exporter runs on port 9100

## Step 3: Monitoring Server (EC2 #2)

* Prometheus scrapes metrics
* Grafana visualizes dashboards

---

# Monitoring Strategy

The system focuses on 4 core observability pillars:

* Latency (performance)
* Error rate (reliability)
* Traffic (usage)
* Resource usage (CPU, memory)

---

#  Alerting

Prometheus alerts trigger based on conditions.

![Prometheus alerts](/assets/alerts.png)

### Example Alert

* High Error Rate > 5%

---

# Security & Logging

## CloudTrail

Tracks all AWS API activity

## CloudWatch

Streams container logs

## GuardDuty

Detects suspicious behavior and threats

---

# Testing

Run unit tests:

```
pytest -v
```


# Author
Kevin ISHIMWE
