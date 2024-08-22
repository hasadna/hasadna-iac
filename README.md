# Hasadna Infrastructure As Code

This repo contains Terraform configurations for managing Hasadna infrastructure as code.

## Running locally

Prerequisites:

* Python3 + Poetry
* [vault binary](https://www.vaultproject.io/downloads)
* Gcloud CLI (Only for initializing datacity instances)

Run following commands from poetry shell:

```
poetry shell
```

Set vault credentials:

```
export VAULT_ADDR=
export VAULT_TOKEN=
```

Set GitHub Token:

```
export GITHUB_TOKEN=...
```

Initialize (should only be done once):

```
terraform init "-backend-config=$(bin/get_backend_config.py)"
```

Set secret envvars:

```
eval "$(bin/get_secret_envvars.py)"
```

Check the plan:

```
terraform plan
```

Apply:

```
terraform apply
```

Save the outputs to Vault:

```
bin/save_outputs_to_vault.py
```