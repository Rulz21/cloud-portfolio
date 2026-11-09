import importlib
import json
import os
import sys

import boto3
import pytest
from moto import mock_aws

# Let the tests find app.py (one folder up)
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

TABLE_NAME = "test-visitor-counter"


@pytest.fixture
def app(monkeypatch):
    """Set up a fake AWS with an empty table, then load app.py against it."""
    monkeypatch.setenv("TABLE_NAME", TABLE_NAME)
    monkeypatch.setenv("AWS_DEFAULT_REGION", "ap-southeast-2")
    # Fake credentials, so the tests can never touch a real AWS account
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")

    with mock_aws():
        boto3.client("dynamodb").create_table(
            TableName=TABLE_NAME,
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        import app as counter_app
        importlib.reload(counter_app)  # reconnect to the fresh fake table
        yield counter_app


def test_first_visit_returns_1(app):
    response = app.lambda_handler({}, None)

    assert response["statusCode"] == 200
    assert json.loads(response["body"]) == {"count": 1}


def test_count_goes_up_by_one_each_visit(app):
    app.lambda_handler({}, None)
    app.lambda_handler({}, None)
    response = app.lambda_handler({}, None)

    assert json.loads(response["body"])["count"] == 3


def test_response_is_json(app):
    response = app.lambda_handler({}, None)

    assert response["headers"]["Content-Type"] == "application/json"