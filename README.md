# Hasadna Infrastructure As Code

This repo contains Terraform configurations for managing Hasadna infrastructure as code.

Every commit to the repo will run terraform plan in GitHub actions, you can check the actions log for details.
To prevent destructive actions, to apply the changes you have to run locally as described below.

## Running locally

Initialize (should only be done once, get the backend config string from vault `Projects/iac/terraform_`):

```
terraform init -backend-config='BACKEND_CONFIG'
```

Set hasadna AWS account keys from Vault `Projects/iac/aws`:

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

Set Kamatera API keys from Vault `Projects/iac/kamatera`:

```
export KAMATERA_API_CLIENT_ID=
export KAMATERA_API_SECRET=
```

Run Terraform commands:

```
terraform plan
```
