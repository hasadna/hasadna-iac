#!/usr/bin/env python3
import os
import sys
import json
import base64
import tempfile
import subprocess
from textwrap import dedent


GOOGLE_SERVICE_ACCOUNT = base64.b64decode(os.environ['TF_VAR_datacity_google_service_account_b64'].encode('utf-8')).decode('utf-8')


def main(service_account_email, vault_path):
    with tempfile.TemporaryDirectory() as tmpdir:
        with open(os.path.join(tmpdir, '.gsa.json'), 'w') as f:
            f.write(GOOGLE_SERVICE_ACCOUNT)
        # create service account hmac key for cloud storage bucket
        res = subprocess.check_output(dedent(f'''
            gcloud -q auth activate-service-account --key-file={os.path.join(tmpdir, '.gsa.json')} >/dev/null
            gcloud -q --project=datacity-k8s storage hmac create {service_account_email} --format=json
            gcloud -q auth revoke >/dev/null || true
        '''), text=True, shell=True)
        hmac = json.loads(res)
        access = hmac['metadata']['accessId']
        secret = hmac['secret']
        print(f'{service_account_email}\n{access}\n{secret}')
        subprocess.check_call([
            'vault', 'kv', 'put', f'kv/{vault_path}', f'hmac_access_key={access}', f'hmac_secret={secret}'
        ])


if __name__ == '__main__':
    main(*sys.argv[1:])
