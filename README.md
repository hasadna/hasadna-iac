# Hasadna Infrastructure As Code

This repo contains Terraform configurations for managing Hasadna infrastructure as code.

## Running locally

Prerequisites:

* Python3 + [uv](https://pypi.org/project/uv/)
* [vault binary](https://www.vaultproject.io/downloads)
* Gcloud CLI
* Docker

Create venv and install dependencies

```
uv sync
```

Make sure to run all following commands from the venv

```
. .venv/bin/activate
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
uv run terraform init "-backend-config=$(uv run bin/get_backend_config.py)"
```

Set secret envvars:

```
eval "$(uv run bin/get_secret_envvars.py)"
```

Check the plan:

```
uv run terraform plan
```

Apply:

```
uv run terraform apply
```

Save the outputs to Vault:

```
uv run bin/save_outputs_to_vault.py
```
