#!/bin/sh
set -eu
environment="${1:?Usage: docker compose run --rm deploy <dev|staging|prod|prod-green>}"
case "$environment" in dev|staging|prod|prod-green) ;; *) echo "Environment must be dev, staging, prod, or prod-green" >&2; exit 2;; esac
: "${TF_STATE_BUCKET:?Set TF_STATE_BUCKET in .env}"
: "${TF_LOCK_TABLE:?Set TF_LOCK_TABLE in .env}"
: "${API_KEY_VALUE:?Set API_KEY_VALUE in .env}"
make "$environment"
