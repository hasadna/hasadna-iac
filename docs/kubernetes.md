# Kubernetes Cluster

## ArgoCD

ArgoCD is the main tool used for managing the Kubernetes cluster. It allows for GitOps-style deployments and provides a web interface to manage applications.

Authorization is handled via GitHub.

## Kubectl

Authorization for kubectl is managed via the same ArgoCD auth using [Pinniped](https://pinniped.dev/).

You need to install Pinniped CLI and the Kubeconfig file from Vault under `Projects/k8s/auth-pinniped-kubeconfig`.

On login you will have an option to choose read-only access this is meant to be used for connecting AI tools to kubectl without the risk of modifying the cluster.
