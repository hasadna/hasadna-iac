# Hasadna Infrastructure As Code

This repo contains Terraform configurations for managing Hasadna infrastructure as code.

## Usage

Run the interactivate initialization, it will prompt for the required values, it is safe to run multiple times to reinitialize or update

```
docker run --pull always -it ghcr.io/hasadna/hasadna-iac/atlantis:latest initialize
```

Start a shell with configured terraform environment, it will ask for required values interactively and run terraform init:

```
docker run --pull always --env-file /etc/hasadna/iac.env -it --network host -v `pwd`:/home/atlantis/hasadna-iac ghcr.io/hasadna/hasadna-iac/atlantis:latest shell
```

Once inside the shell, run Terraform commands:

```
terraform plan
terraform apply
```

Vault token is short-lived, so for long sessions you may need to re-authenticate and set the new token with `export VAULT_TOKEN=...`

If you want to make changes to the code, you can mount the current directory into the container with `-v `pwd`:/home/atlantis/hasadna-iac`
