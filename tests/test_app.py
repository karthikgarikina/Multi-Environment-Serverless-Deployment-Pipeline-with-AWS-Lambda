import json
import os
import sys
from pathlib import Path

# Add lambda-src/hello_function to module search path
sys.path.insert(0, str(Path(__file__).parents[1] / "lambda-src" / "hello_function"))
from app import lambda_handler


def test_dev_environment(monkeypatch):
    monkeypatch.setenv("ENVIRONMENT", "dev")
    monkeypatch.delenv("VERSION", raising=False)
    response = lambda_handler({}, None)
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body == {"message": "Hello from Dev!"}
    assert response["headers"]["Content-Type"] == "application/json"
    assert response["headers"]["Access-Control-Allow-Origin"] == "*"


def test_staging_environment(monkeypatch):
    monkeypatch.setenv("ENVIRONMENT", "staging")
    monkeypatch.delenv("VERSION", raising=False)
    response = lambda_handler({}, None)
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body == {"message": "Hello from Staging!"}


def test_prod_blue_environment(monkeypatch):
    monkeypatch.setenv("ENVIRONMENT", "prod")
    monkeypatch.setenv("VERSION", "Blue")
    response = lambda_handler({}, None)
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body == {"message": "Hello from Prod (Blue)!"}


def test_prod_green_environment(monkeypatch):
    monkeypatch.setenv("ENVIRONMENT", "prod")
    monkeypatch.setenv("VERSION", "Green")
    response = lambda_handler({}, None)
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body == {"message": "Hello from Prod (Green)!"}


def test_error_handling(monkeypatch):
    def bad_env(*args, **kwargs):
        raise RuntimeError("simulated env failure")

    monkeypatch.setattr(os.environ, "get", bad_env)
    response = lambda_handler({}, None)
    assert response["statusCode"] == 500
    assert json.loads(response["body"]) == {"message": "Internal server error"}
