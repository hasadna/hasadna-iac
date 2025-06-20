#!/usr/bin/env python3
import os
import sys
import json
import base64
import subprocess
from copy import deepcopy
from textwrap import dedent

from nacl.public import PrivateKey, PublicKey, Box


ENCRYPTED_USER_DATA = {
    'ssh_private_key': {
        'multiline': True,
        'description': 'SSH private key for accessing servers',
    },
    'github_token': {
        'description': 'GitHub Personal Access Token with full permissions',
    },
}


def vault_read(vault_addr, vault_token, path):
    p = subprocess.run(["vault", "read", f"kv/data/{path}", "-format=json"], env={
        **os.environ,
        'VAULT_ADDR': vault_addr,
        'VAULT_TOKEN': vault_token
    }, capture_output=True)
    if p.returncode == 0:
        return json.loads(p.stdout)['data']['data']
    else:
        return None


def vault_write_encrypt_data(vault_addr, vault_token, box, path, value):
    encrypted_value = box.encrypt(value.encode())
    subprocess.check_call(["vault", "kv", "put", f"kv/{path}", f"data={base64.b64encode(encrypted_value).decode()}"], env={
        **os.environ,
        'VAULT_ADDR': vault_addr,
        'VAULT_TOKEN': vault_token
    })


def verify_vault(vault_addr, vault_token):
    ttl_seconds = json.loads(subprocess.check_output(
        ["vault", "token", "lookup", "-format=json"],
        env={
            **os.environ,
            'VAULT_ADDR': vault_addr,
            'VAULT_TOKEN': vault_token
        }
    ))['data']['ttl']
    ttl_hours = ttl_seconds / 3600
    print(f'Vault token TTL: {ttl_hours} hours')


def init_ssh_config(tempdir, ssh_private_key, rke2_ssh_config, vault_addr, vault_token):
    os.makedirs(os.path.join(tempdir, '.ssh'), exist_ok=True)
    with open(os.path.join(tempdir, '.ssh', 'private_key'), 'w') as f:
        f.write(ssh_private_key)
    os.chmod(os.path.join(tempdir, '.ssh', 'private_key'), 0o600)
    with open(os.path.join(tempdir, '.ssh', 'known_hosts'), 'w') as f:
        f.write(vault_read(vault_addr, vault_token, f'Projects/iac/ssh_rke2_known_hosts')['known_hosts'])
    with open(os.path.join(tempdir, '.ssh', 'config'), 'w') as f:
        f.write(dedent(f'''
            Host *
              IdentityFile {os.path.join(tempdir, '.ssh', 'private_key')}
              UserKnownHostsFile {os.path.join(tempdir, '.ssh', 'known_hosts')}
        '''))
        f.write("\n")
        f.write(rke2_ssh_config)
    ssh_config = dedent(f'''
        Include {os.path.join(tempdir, '.ssh', 'config')}
    ''')
    if os.path.exists(os.path.expanduser("~/.ssh/config")):
        print('ssh config already exists, will not overwrite')
        print('You can manually add the following to your ~/.ssh/config:')
        print(ssh_config)
    else:
        os.makedirs(os.path.expanduser("~/.ssh"), exist_ok=True)
        with open(os.path.expanduser("~/.ssh/config"), 'w') as f:
            f.write(ssh_config)


def generate_private_public_key():
    private_key = PrivateKey.generate()
    private_key_b64 = base64.b64encode(private_key.encode()).decode()
    public_key_b64 = base64.b64encode(private_key.public_key.encode()).decode()
    return private_key_b64, public_key_b64


def set_encrypted_user_data(vault_addr, vault_token, github_username, private_key_b64, public_key_b64):
    private_key = PrivateKey(base64.b64decode(private_key_b64))
    public_key = PublicKey(base64.b64decode(public_key_b64))
    box = Box(private_key, public_key)
    data = deepcopy(ENCRYPTED_USER_DATA)
    print("Setting encrypted user data in Vault")
    print('The data is encrypted with your private key, only you can decrypt it.')
    for key in data:
        config = data[key]
        encrypted_value = vault_read(vault_addr, vault_token, f'Projects/iac/encrypted_user_data/{github_username}/{key}')
        if encrypted_value is not None:
            encrypted_value = encrypted_value['data']
        if encrypted_value:
            decrypted_value = box.decrypt(base64.b64decode(encrypted_value.encode())).decode()
            print(f'Found existing encrypted value for {key}, current value: {decrypted_value}')
            print('To keep existing value, press Enter at the prompt.')
        print(config['description'])
        if config.get('multiline'):
            print(f'Paste value for {key}: ')
            value = []
            while True:
                try:
                    line = input()
                    if line == '':
                        break
                    value.append(line)
                except EOFError:
                    break
            value = '\n'.join(value)
        else:
            value = input(f'{key}: ')
        value = value.strip()
        if value:
            vault_write_encrypt_data(vault_addr, vault_token, box, f'Projects/iac/encrypted_user_data/{github_username}/{key}', value)
        else:
            assert encrypted_value, f'Value for {key} cannot be empty'


def main_initialize():
    vault_token = os.getenv('VAULT_TOKEN')
    if not vault_token:
        print('Get your Vault Token by logging into the Vault UI, click on your profile icon and "Copy Token"')
        vault_token = input("Vault Token: ")
    vault_addr = os.getenv('VAULT_ADDR')
    if not vault_addr:
        vault_addr = input("Vault Address: https://")
        vault_addr = f"https://{vault_addr}".rstrip('/')
    verify_vault(vault_addr, vault_token)
    github_username = os.getenv('GITHUB_USERNAME')
    if not github_username:
        github_username = input("GitHub User Name: ")
    data = vault_read(vault_addr, vault_token, f'Projects/iac/encrypted_user_data/{github_username}/public_key')
    if data is None:
        print('No public key found, generating a new key pair')
        private_key = PrivateKey.generate()
        private_key_b64 = base64.b64encode(private_key.encode()).decode()
        public_key_b64 = base64.b64encode(private_key.public_key.encode()).decode()
    else:
        print("Found existing public key in Vault")
        public_key_b64 = data['key']
        private_key_b64 = input('Private Key: ')
    docker_envfile = dedent(f'''
        VAULT_ADDR={vault_addr}
        GITHUB_USERNAME={github_username}
        PRIVATE_KEY={private_key_b64}
        PUBLIC_KEY={public_key_b64}
    ''')
    print()
    print("Copy and keep the following env vars in a safe place")
    print("To run locally also store them in `/etc/hasadna/iac.env`")
    print(docker_envfile)
    input('Press Enter to continue...')
    set_encrypted_user_data(vault_addr, vault_token, github_username, private_key_b64, public_key_b64)


def main_shell():
    vault_token = os.getenv('VAULT_TOKEN')
    if vault_token:
        print("WARNING! Using Vault Token from environment variable, this is not secure!")
    else:
        print('Get your Vault Token by logging into the Vault UI, click on your profile icon and "Copy Token"')
        vault_token = input("Vault Token: ")
    vault_addr = os.getenv('VAULT_ADDR')
    github_username = os.getenv('GITHUB_USERNAME')
    private_key_b64 = os.getenv('PRIVATE_KEY')
    public_key_b64 = os.getenv('PUBLIC_KEY')
    tempdir = os.getenv('TEMPDIR')
    assert vault_token and vault_addr and github_username and private_key_b64 and public_key_b64 and tempdir
    verify_vault(vault_addr, vault_token)
    private_key = PrivateKey(base64.b64decode(private_key_b64))
    public_key = PublicKey(base64.b64decode(public_key_b64))
    box = Box(private_key, public_key)
    data = deepcopy(ENCRYPTED_USER_DATA)
    for key in data:
        encrypted_value = vault_read(vault_addr, vault_token, f'Projects/iac/encrypted_user_data/{github_username}/{key}')
        if encrypted_value is not None:
            encrypted_value = encrypted_value['data']
        assert encrypted_value, f'missing encrypted user data: {key}, please run `initialize` command first'
        data[key]['value'] = box.decrypt(base64.b64decode(encrypted_value.encode())).decode()
    with open(os.path.join(tempdir, 'kubeconfig'), 'w') as f:
        f.write(vault_read(vault_addr, vault_token, f'Projects/k8s/auth-pinniped-kubeconfig')['kubeconfig'])
    subprocess.check_call(['kubectl', 'auth', 'whoami'], env={**os.environ, 'KUBECONFIG': os.path.join(tempdir, 'kubeconfig')})
    backend_config = vault_read(vault_addr, vault_token, 'Projects/iac/terraform_')['backend-config']
    subprocess.check_call(
        ['terraform', 'init', '-backend-config=' + backend_config],
        env={**os.environ, 'VAULT_ADDR': vault_addr, 'VAULT_TOKEN': vault_token},
        cwd=os.path.expanduser('~/hasadna-iac')
    )
    rke2_ssh_config = subprocess.check_output(['terraform', 'output', '-raw', 'rke2_ssh_config'], env={
        **os.environ,
        'VAULT_ADDR': vault_addr,
        'VAULT_TOKEN': vault_token
    }, cwd=os.path.expanduser('~/hasadna-iac')).decode().strip()
    init_ssh_config(tempdir, data['ssh_private_key']['value'], rke2_ssh_config, vault_addr, vault_token)
    with open(os.path.join(tempdir, 'env'), 'w') as f:
        f.write(subprocess.check_output(['python', os.path.expanduser('~/hasadna-iac/bin/get_secret_envvars.py')], env={
            **os.environ,
            'VAULT_ADDR': vault_addr,
            'VAULT_TOKEN': vault_token
        }, cwd=os.path.expanduser('~/hasadna-iac')).decode())
        f.write(dedent(f'''
            export VAULT_ADDR={vault_addr}
            export VAULT_TOKEN={vault_token}
            export PRIVATE_KEY=
            export KUBECONFIG={os.path.join(tempdir, 'kubeconfig')}
            export TF_VAR_rke2_kubeconfig_path={os.path.join(tempdir, 'kubeconfig')}
            export GITHUB_TOKEN={data['github_token']['value']}
        '''))


def main(cmd, *args):
    if cmd == 'initialize':
        main_initialize()
    elif cmd == 'shell':
        main_shell()
    else:
        raise Exception(f'Unknown command: {cmd}')


if __name__ == '__main__':
    main(*sys.argv[1:])
