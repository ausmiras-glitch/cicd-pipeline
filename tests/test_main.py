from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["service"] == "cicd-pipeline"


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_version_has_fields():
    body = client.get("/version").json()
    assert {"version", "python", "started_at"} <= body.keys()


def test_echo():
    response = client.post("/echo", json={"message": "  hello  "})
    assert response.status_code == 200
    assert response.json() == {"echo": "hello", "length": 5}


def test_echo_rejects_blank():
    response = client.post("/echo", json={"message": "   "})
    assert response.status_code == 422
