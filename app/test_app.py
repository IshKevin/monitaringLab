import pytest

from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_home_endpoint(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.is_json
    assert response.get_json() == {"message": "Monitoring App Running"}


def test_error_endpoint(client):
    response = client.get("/error")
    assert response.status_code == 500
    assert b"error occurred" in response.data


def test_slow_endpoint(client):
    response = client.get("/slow")
    assert response.status_code == 200
    assert response.data == b"slow response"


def test_metrics_endpoint_includes_prometheus_metrics(client):
    client.get("/")
    client.get("/error")
    response = client.get("/metrics")
    assert response.status_code == 200
    body = response.data.decode("utf-8")
    assert "app_requests_total" in body
    assert "app_request_latency_seconds" in body
