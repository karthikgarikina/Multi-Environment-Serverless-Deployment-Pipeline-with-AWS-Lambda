terraform {
  required_version = ">= 1.6.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

locals {
  tags = {
    Project     = var.project_name
    Environment = var.environment_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

module "lambda" {
  source           = "../../modules/lambda"
  function_name    = "${var.project_name}-${var.environment_name}-hello"
  environment_name = var.environment_name
  version_label    = var.deployment_color
  source_dir       = "${path.root}/../../../lambda-src/hello_function"
  tags             = local.tags
}

# Both aliases exist permanently. ignore_changes lets the CI workflow publish
# to the inactive alias and validate without Terraform undoing the switch.
resource "aws_lambda_alias" "blue" {
  name             = "blue"
  description      = "Stable blue production version"
  function_name    = module.lambda.function_name
  function_version = module.lambda.version

  lifecycle {
    ignore_changes = [function_version]
  }
}

resource "aws_lambda_alias" "green" {
  name             = "green"
  description      = "Candidate green production version"
  function_name    = module.lambda.function_name
  function_version = module.lambda.version

  lifecycle {
    ignore_changes = [function_version]
  }
}

module "api" {
  source               = "../../modules/api-gateway"
  name                 = "${var.project_name}-${var.environment_name}-api"
  stage_name           = var.api_gateway_stage_name
  lambda_invoke_arn    = replace(module.lambda.invoke_arn, "/invocations", ":${var.active_color}/invocations")
  lambda_function_name = "${module.lambda.function_name}:${var.active_color}"
  api_key_value        = var.api_key_value
  tags                 = local.tags

  depends_on = [
    aws_lambda_alias.blue,
    aws_lambda_alias.green,
  ]
}
