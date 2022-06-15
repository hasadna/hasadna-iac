# Hasadna Infrastructure As Code

This repo contains Terraform configurations for managing Hasadna infrastructure as code.

## Running locally

Initialize (should only be done once, get the backend config string from vault `Projects/iac/terraform_`):

```
terraform init -backend-config='BACKEND_CONFIG'
```

Set hasadna AWS account keys:

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```
