#!/usr/bin/env bash

set -eo pipefail

TMPDIR=$(mktemp -d)
echo TMPDIR: $TMPDIR
cd $TMPDIR
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
curl -LO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
git clone --depth 1 https://github.com/hasadna/hasadna-k8s.git
cd hasadna-k8s
apps/hasadna-argocd/manifests/render_templates.sh
../kustomize build apps/hasadna-argocd/manifests | ../kubectl apply -n argocd -f -
cd
rm -rf $TMPDIR
