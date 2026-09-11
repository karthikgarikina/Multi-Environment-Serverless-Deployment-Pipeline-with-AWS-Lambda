FROM python:3.12-slim
ARG TERRAFORM_VERSION=1.9.8
WORKDIR /workspace
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip make && curl -fsSLo /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && unzip -q /tmp/terraform.zip -d /usr/local/bin && rm -rf /var/lib/apt/lists/* /tmp/terraform.zip
COPY requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt awscli
COPY . .
CMD ["sh", "scripts/check.sh"]
