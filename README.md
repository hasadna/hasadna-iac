# Hasadna Infrastructure As Code

This repo contains Terraform configurations for managing Hasadna infrastructure as code.

## Usage

Run the interactivate initialization, it will prompt for the required values, it is safe to run multiple times to reinitialize or update

```
bin/docker_run.sh initialize
```

Start a shell with configured terraform environment, it will ask for required values and perform interactive login:

```
bin/docker_run.sh shell
```

Once inside the shell, run Terraform commands:

```
terraform plan
terraform apply
```

Vault token is short-lived, so for long sessions you may need to re-authenticate and set the new token with `export VAULT_TOKEN=...`
