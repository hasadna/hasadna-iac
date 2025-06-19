# Hasadna Infrastructure As Code

This repo contains Terraform configurations for managing Hasadna infrastructure as code.

## Usage

First time users should run the interactivate initialization, it will prompt for the required values, it is safe to run multiple times to reinitialize or update:

```
docker run --pull always -it ghcr.io/hasadna/hasadna-iac/atlantis:latest initialize
```

Start a shell with configured terraform environment, it will ask for required values interactively and run terraform init:

```
docker run --pull always --env-file /etc/hasadna/iac.env -it ghcr.io/hasadna/hasadna-iac/atlantis:latest shell
```

Once inside the shell, run Terraform commands:

```
terraform plan
terraform apply
```

If you want to make changes to the code, you can mount the current directory into the container with `-v `pwd`:/home/atlantis/hasadna-iac`
