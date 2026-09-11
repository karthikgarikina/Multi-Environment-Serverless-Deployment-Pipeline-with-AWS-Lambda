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
  version_label    = ""
  source_dir       = "${path.root}/../../../lambda-src/hello_function"
  tags             = local.tags
}

module "api" {
  source               = "../../modules/api-gateway"
  name                 = "${var.project_name}-${var.environment_name}-api"
  stage_name           = var.api_gateway_stage_name
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
  api_key_value        = "${var.api_key_value}_staging"
  tags                 = local.tags
}
