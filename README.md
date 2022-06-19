# Hasadna Infrastructure As Code

This repo contains Terraform configurations for managing Hasadna infrastructure as code.

Every commit to the repo will run terraform plan in GitHub actions, you can check the actions log for details.
To prevent destructive actions, to apply the changes you have to run locally as described below.

## Running locally

Prerequisites:

* Python3
* [vault binary](https://www.vaultproject.io/downloads)

Set vault credentials:

```
export VAULT_ADDR=
export VAULT_TOKEN=
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