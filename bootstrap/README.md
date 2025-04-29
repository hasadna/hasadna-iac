# Bootstrap

This directory contains information for initial infrastructure setup and roles which require elevated permissions.

It should run rarely, usually only when more permissions are needed for Terraform.

## Usage

Follow the README to set up your environment.

Login to your personal GCP account which should have owner permissions on the relevant projects:

```
gcloud auth application-default login
```

Initialize the bootstrap project:

```
uv run terraform -chdir=bootstrap init \
     -backend-config=schema_name=bootstrap \
    "-backend-config=$(uv run bin/get_backend_config.py)"
```

Apply:

```
uv run terraform -chdir=bootstrap apply
```
