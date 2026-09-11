.PHONY: all test check fmt validate dev staging prod prod-green destroy-dev destroy-staging destroy-prod clean

AWS_REGION ?= us-east-1
TF_STATE_BUCKET ?= REPLACE_ME
TF_LOCK_TABLE ?= REPLACE_ME
API_KEY_VALUE ?= REPLACE_ME
OWNER ?= $(PROJECT_OWNER)
PROD_ACTIVE_COLOR ?= blue
PROD_DEPLOYMENT_COLOR ?= Blue

define tf
	terraform -chdir=terraform/environments/$(1) init -reconfigure \
		-backend-config="bucket=$(TF_STATE_BUCKET)" \
		-backend-config="key=$(1).tfstate" \
		-backend-config="region=$(AWS_REGION)" \
		-backend-config="dynamodb_table=$(TF_LOCK_TABLE)" \
		-backend-config="encrypt=true"
	terraform -chdir=terraform/environments/$(1) apply -auto-approve \
		-var="region=$(AWS_REGION)" \
		-var="owner=$(OWNER)" \
		-var="api_key_value=$(API_KEY_VALUE)"
endef

all: check

test:
	docker compose run --rm test

check:
	docker compose run --rm check

fmt:
	terraform fmt -recursive terraform

validate:
	terraform -chdir=terraform/environments/dev init -backend=false && terraform -chdir=terraform/environments/dev validate
	terraform -chdir=terraform/environments/staging init -backend=false && terraform -chdir=terraform/environments/staging validate
	terraform -chdir=terraform/environments/prod init -backend=false && terraform -chdir=terraform/environments/prod validate

dev:
	$(call tf,dev)

staging:
	$(call tf,staging)

prod:
	terraform -chdir=terraform/environments/prod init -reconfigure \
		-backend-config="bucket=$(TF_STATE_BUCKET)" \
		-backend-config="key=prod.tfstate" \
		-backend-config="region=$(AWS_REGION)" \
		-backend-config="dynamodb_table=$(TF_LOCK_TABLE)" \
		-backend-config="encrypt=true"
	terraform -chdir=terraform/environments/prod apply -auto-approve \
		-var="region=$(AWS_REGION)" \
		-var="owner=$(OWNER)" \
		-var="api_key_value=$(API_KEY_VALUE)" \
		-var="active_color=$(PROD_ACTIVE_COLOR)" \
		-var="deployment_color=$(PROD_DEPLOYMENT_COLOR)"

prod-green:
	terraform -chdir=terraform/environments/prod init -reconfigure \
		-backend-config="bucket=$(TF_STATE_BUCKET)" \
		-backend-config="key=prod.tfstate" \
		-backend-config="region=$(AWS_REGION)" \
		-backend-config="dynamodb_table=$(TF_LOCK_TABLE)" \
		-backend-config="encrypt=true"
	terraform -chdir=terraform/environments/prod apply -auto-approve \
		-var="region=$(AWS_REGION)" \
		-var="owner=$(OWNER)" \
		-var="api_key_value=$(API_KEY_VALUE)" \
		-var="active_color=green" \
		-var="deployment_color=Green"

destroy-dev:
	terraform -chdir=terraform/environments/dev destroy -auto-approve -var="region=$(AWS_REGION)" -var="owner=$(OWNER)" -var="api_key_value=$(API_KEY_VALUE)"

destroy-staging:
	terraform -chdir=terraform/environments/staging destroy -auto-approve -var="region=$(AWS_REGION)" -var="owner=$(OWNER)" -var="api_key_value=$(API_KEY_VALUE)"

destroy-prod:
	terraform -chdir=terraform/environments/prod destroy -auto-approve -var="region=$(AWS_REGION)" -var="owner=$(OWNER)" -var="api_key_value=$(API_KEY_VALUE)"

clean: destroy-dev destroy-staging destroy-prod
