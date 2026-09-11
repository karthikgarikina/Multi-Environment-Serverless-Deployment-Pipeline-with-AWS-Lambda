"""Small, stateless Lambda behind API Gateway."""
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(os.getenv("LOG_LEVEL", "INFO"))


def lambda_handler(event, context):
    """Return an environment-aware greeting and never expose internal errors."""
    try:
        environment = os.environ.get("ENVIRONMENT", "unknown").title()
        version = os.environ.get("VERSION", "").strip()
        suffix = f" ({version})" if version else ""
        logger.info("hello request received; request_id=%s", getattr(context, "aws_request_id", "local"))
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": os.environ.get("CORS_ALLOW_ORIGIN", "*"),
                "Access-Control-Allow-Methods": "GET,OPTIONS",
            },
            "body": json.dumps({"message": f"Hello from {environment}{suffix}!"}),
        }
    except Exception:  # pragma: no cover - defensive Lambda boundary
        logger.exception("Unhandled error processing hello request")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Internal server error"}),
        }
