# Multi-Environment Serverless Deployment Pipeline with AWS Lambda

[![Terraform](https://img.shields.io/badge/Terraform-v1.9.8-844FBA?style=flat-square&logo=terraform)](https://www.terraform.io)
[![AWS](https://img.shields.io/badge/AWS-Serverless-FF9900?style=flat-square&logo=amazon-aws)](https://aws.amazon.com)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=flat-square&logo=python)](https://python.org)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=flat-square&logo=docker)](https://www.docker.com)
[![CI/CD](https://img.shields.io/badge/GitHub_Actions-Automated-2088FF?style=flat-square&logo=githubactions)](https://github.com)

A robust, multi-environment CI/CD delivery pipeline deploying a serverless REST API using AWS Lambda and API Gateway, with infrastructure fully managed by modular Terraform across `dev`, `staging`, and `prod`. Features zero-downtime **Blue/Green production cutover**, automated CloudWatch monitoring and alarms, manual approval gates, and containerized local validation.

---

## System Architecture

```mermaid
flowchart LR
    subgraph Git Workflow
        F[feature/* branch] -->|Push| DEV[Deploy to Dev]
        M[main branch] -->|Push| GATE{Manual Approval Gate}
        GATE -->|Approved| STG[Deploy to Staging]
        STG --> BG[Prod Blue/Green Release]
    end

    subgraph AWS Production Blue/Green Cutover
        BG --> P1[1. Publish Green Version]
        P1 --> P2[2. Validate green Alias Directly]
        P2 -->|Pass| P3[3. Shift API Gateway to Green Alias]
        P2 -->|Fail| P4[Rollback: Retain Blue Alias]
    end

    subgraph Serverless Architecture
        APIGW[API Gateway REST API] -->|GET /hello with x-api-key| LAMBDA[Lambda Python 3.12]
        LAMBDA --> CWL[CloudWatch Log Group]
        LAMBDA --> CWA[CloudWatch Alarm: Errors > 0]
        APIGW --> UP[Usage Plan & Key]
    end
```

---

## Core Capabilities & Architecture

- **Multi-Environment Isolation**: Root configurations (`terraform/environments/{dev,staging,prod}`) deploy identical modular infrastructure into isolated namespaces and remote state keys with DynamoDB locking.
- **Stateless API Design**: Python 3.12 Lambda behind API Gateway (`GET /hello`) with CORS preflight support, least-privilege IAM roles, and environment-aware responses:
  - Dev: `{"message": "Hello from Dev!"}`
  - Staging: `{"message": "Hello from Staging!"}`
  - Prod (Blue): `{"message": "Hello from Prod (Blue)!"}`
  - Prod (Green): `{"message": "Hello from Prod (Green)!"}`
- **Production Zero-Downtime Blue/Green**: Uses immutable Lambda versioning and persistent `blue` and `green` aliases. Candidate green versions are deployed and validated in isolation via AWS CLI before shifting API Gateway traffic.
- **Endpoint Security**: Secured using required `x-api-key` headers associated with API Gateway Usage Plans.
- **Observability & Proactive Monitoring**: CloudWatch log streams (14-day retention) paired with Metric Alarms triggering on `Errors > 0` over 5-minute evaluation periods.
- **CI/CD Automation**: GitHub Actions pipeline automating linting, pytest, Terraform formatting, dev deploys on feature branches, manual approval gates for staging, and production blue/green traffic shifting.

---

## Quick Start & Local Commands

### 1. Run Automated Validation Suite (One Command)
Runs pytest, Terraform formatting checks, and validates all environments inside a hermetic container:
```bash
docker compose run --rm check
```

### 2. Configure Credentials (`.env`)
Copy `.env.example` to `.env` and supply your AWS credentials:
```env
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
TF_STATE_BUCKET=your-terraform-state-bucket
TF_LOCK_TABLE=your-terraform-lock-table
PROJECT_OWNER=Karthik
API_KEY_VALUE=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
```

### 3. Deploy Environments
```bash
# Deploy Dev
docker compose run --rm deploy dev

# Deploy Staging
docker compose run --rm deploy staging

# Deploy Prod (Blue)
docker compose run --rm deploy prod

# Shift Prod to Green (Zero-Downtime)
docker compose run --rm deploy prod-green
```

### 4. Verify Endpoints
```bash
# Dev
curl -H "x-api-key: $API_KEY" "<DEV_URL>"
# Response: {"message": "Hello from Dev!"}

# Staging
curl -H "x-api-key: ${API_KEY}_staging" "<STAGING_URL>"
# Response: {"message": "Hello from Staging!"}

# Prod (Initial Blue)
curl -H "x-api-key: ${API_KEY}_prod" "<PROD_URL>"
# Response: {"message": "Hello from Prod (Blue)!"}

# Prod (After Green Shift)
curl -H "x-api-key: ${API_KEY}_prod" "<PROD_URL>"
# Response: {"message": "Hello from Prod (Green)!"}
```

---

## CI/CD Pipeline & GitHub Configuration

### 1. Repository Secrets & Variables
Set in **Settings → Secrets and variables → Actions**:
- **Secrets**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `TF_STATE_BUCKET`, `TF_LOCK_TABLE`, `API_KEY_VALUE`
- **Variables**: `PROJECT_OWNER`

### 2. Environments & Approval Gate
In **Settings → Environments**:
- Create `dev`, `staging`, and `prod`.
- On **`staging`**, enable **Required reviewers** to enforce the manual sign-off gate before promotion.

### 3. Workflow Triggers
- **Pushes to `feature/**`**: Runs test suite, formatting checks, and applies changes to `dev`.
- **Pushes to `main`**: Runs tests, pauses at the staging approval gate, deploys to `staging`, and executes the automated Blue/Green production cutover.

---

## Verification & Submission Evidence

### Checkpoint 1: Dev Deployment on Feature Branch
![Feature Branch CI/CD Run](docs/screenshots/dev_pipeline_run.png)
*Automated feature branch workflow run showing test execution and successful dev apply.*

---

### Checkpoint 2: Staging Manual Approval Gate
![Staging Manual Approval Gate](docs/screenshots/staging_manual_approval.png)
*Pipeline execution paused at the staging manual review gate awaiting explicit approval.*

---

### Checkpoint 3: API Gateway Stages & Security
![API Gateway Stages](docs/screenshots/api_gateway_stages.png)
*API Gateway console displaying active stages, deployment timestamps, and Usage Plan key associations.*

---

### Checkpoint 4: Dev Endpoint Verification
![Dev Endpoint Response](docs/screenshots/dev_curl_response.png)
*Dev endpoint returning 200 OK with `{"message": "Hello from Dev!"}`.*

---

### Checkpoint 5: Staging Endpoint Verification
![Staging Endpoint Response](docs/screenshots/staging_curl_response.png)
*Staging endpoint returning 200 OK with `{"message": "Hello from Staging!"}`.*

---

### Checkpoint 6: Lambda Aliases (`blue` & `green`)
![Lambda Aliases](docs/screenshots/lambda_aliases.png)
*AWS Lambda Console showing the published function versions alongside active `blue` and `green` aliases.*

---

### Checkpoint 7: Prod Initial Response (Blue)
![Prod Blue Endpoint Response](docs/screenshots/prod_blue_response.png)
*Production endpoint returning `{"message": "Hello from Prod (Blue)!"}`.*

---

### Checkpoint 8: Prod Post-Cutover Response (Green)
![Prod Green Endpoint Response](docs/screenshots/prod_green_response.png)
*Production endpoint returning `{"message": "Hello from Prod (Green)!"}` after traffic cutover.*

---

### Checkpoint 9: CloudWatch Monitoring & Alarm
![CloudWatch Logs and Alarm](docs/screenshots/cloudwatch_alarm.png)
*CloudWatch alarm showing OK state and `Errors > 0 for 5 minutes` threshold.*

---

## Demo Video

https://youtu.be/nhJE1IYlqhg

---

## Teardown
```bash
docker compose run --rm deploy make destroy-dev
docker compose run --rm deploy make destroy-staging
docker compose run --rm deploy make destroy-prod
```
