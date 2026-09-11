#!/bin/sh
set -eu
pytest -q
terraform fmt -check -recursive terraform
for environment in dev staging prod; do
  terraform -chdir="terraform/environments/$environment" init -backend=false -input=false
  terraform -chdir="terraform/environments/$environment" validate
done
echo "All checks passed."
