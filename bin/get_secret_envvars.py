#!/usr/bin/env python3
import os
import json
import functools
import subprocess


@functools.lru_cache(None)
def vault_read(path):
    return json.loads(subprocess.check_output(['vault', 'read', f'kv/data/{path}', '-format=json']))['data']['data']


def main():
    if not os.path.exists('.kubeconfig'):
        with open('.kubeconfig', 'w') as f:
            f.write(vault_read('Projects/iac/k8s')['kubeconfig'])
    values = {
        'AWS_ACCESS_KEY_ID': vault_read('Projects/iac/aws')['AWS_ACCESS_KEY_ID'],
        'AWS_SECRET_ACCESS_KEY': vault_read('Projects/iac/aws')['AWS_SECRET_ACCESS_KEY'],
        'KAMATERA_API_CLIENT_ID': vault_read('Projects/iac/kamatera')['client_id'],
        'KAMATERA_API_SECRET': vault_read('Projects/iac/kamatera')['secret'],
        'KUBE_CONFIG_PATH': '.kubeconfig',
        'TF_VAR_cloudflare_api_token': vault_read('Projects/iac/cloudflare')['api_token'],
        'TF_VAR_domain_infra_1': vault_read('Projects/iac/domains')['infra_1']
    }
    envvars = []
    for k, v in values.items():
        envvars.append(f'export {k}="{v}"')
    print('\n'.join(envvars))
    

if __name__ == "__main__":
    main()
