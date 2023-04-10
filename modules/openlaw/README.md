# OpenLaw Infrastructure

The OpenLaw infrastructure is managed and deployed differently then the rest of the infrastructure.
Following document describes where to find the relevant components and how they are managed.

Infrastructure as code is defined here: https://git.org.il/resource-il/openlaw-infra
To get permissions - Ask admin to create an account for you on git.org.il and give you relevant permissions.

The infrastructure uses Ansible to set up a server hosted on Contabo (account is not managed by Hasadna), 
the server contains all the infra components, including a Kubernetes k0s cluster (single server) which hosts
the app components.

Relevant secrets are stored in Ansible Vault as part of the repo, the password as well as a kubeconfig file are
available [here](https://git.org.il/groups/resource-il/-/settings/ci_cd) under variables.
