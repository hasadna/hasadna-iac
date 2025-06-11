#!/usr/bin/env python3
import os
import json
import base64
import functools
import subprocess


@functools.lru_cache(None)
def vault_read(path):
    return json.loads(subprocess.check_output(['vault', 'read', f'kv/data/{path}', '-format=json']))['data']['data']


def main():
    values = {
        'AWS_ACCESS_KEY_ID': vault_read('Projects/iac/aws')['AWS_ACCESS_KEY_ID'],
        'AWS_SECRET_ACCESS_KEY': vault_read('Projects/iac/aws')['AWS_SECRET_ACCESS_KEY'],
        'KAMATERA_API_CLIENT_ID': vault_read('Projects/iac/kamatera')['client_id'],
        'KAMATERA_API_SECRET': vault_read('Projects/iac/kamatera')['secret'],
        'WASABI_ACCESS_KEY_ID': vault_read('Projects/iac/wasabi')['access-key'],
        'WASABI_SECRET_ACCESS_KEY': vault_read('Projects/iac/wasabi')['secret-key'],
        'TF_VAR_cloudflare_api_token': vault_read('Projects/iac/cloudflare')['api_token'],
        'TF_VAR_ssh_private_key': vault_read('Projects/iac/ssh')['id_ed25519'],
        'TF_VAR_hasadna_ssh_access_point_ssh_port': vault_read('Projects/iac/ssh')['hasadna_ssh_access_point_ssh_port'],
        'TF_VAR_datacity_google_service_account_b64': base64.b64encode(vault_read('Projects/datacity/iac')['terraform_google_service_account'].encode()).decode(),
        'STATUSCAKE_API_TOKEN': vault_read('Projects/iac/statuscake')['api_token'],
        'TF_VAR_ssh_authorized_keys': vault_read('Projects/iac/ssh')['authorized_keys'],
        'TF_VAR_vault_addr': os.environ.get('VAULT_ADDR') or '',
        'TF_VAR_default_admin_email': vault_read('Projects/iac/k8s')['default_admin_email'],
        'TF_VAR_rke2_kubeconfig_path': vault_read('Projects/iac/k8s')['rke2_kubeconfig_path'],
        'KUBECONFIG': vault_read('Projects/iac/k8s')['rke2_kubeconfig_path'],
    }
    envvars = []
    for k, v in values.items():
        envvars.append(f'export {k}="{v}"')
    print('\n'.join(envvars))
    

if __name__ == "__main__":
    main()
