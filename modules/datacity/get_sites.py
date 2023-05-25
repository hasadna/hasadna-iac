import os
import sys
import json
import base64

import requests
from ruamel import yaml


GITHUB_TOKEN = os.environ.get('GITHUB_TOKEN')


def get_github_headers():
    return {'Authorization': f'Bearer {GITHUB_TOKEN}'} if GITHUB_TOKEN else {}


def get_sites():
    res = requests.get('https://api.github.com/repos/hasadna/datacity-k8s/contents/instances', headers=get_github_headers())
    res.raise_for_status()
    res_text = res.text
    try:
        res_json = json.loads(res_text)
    except Exception as e:
        raise Exception(f'failed to parse json: {res_text}') from e
    for instance in res_json:
        try:
            if instance['type'] == 'file':
                continue
            name = instance['name']
            content = base64.b64decode(requests.get(f'https://api.github.com/repos/hasadna/datacity-k8s/contents/instances/{name}/values.yaml', headers=get_github_headers()).json()['content'])
            values = yaml.safe_load(content)
            if values.get('active') and values.get('ready'):
                yield {
                    'name': name,
                    'url': values['siteUrl']
                }
        except Exception as e:
            raise Exception(f'failed to parse instance\n--- res json ---\n{res_json}\n\n--- instance ---\n{instance}') from e


def main(debug):
    sites = list(get_sites())
    if debug:
        print(json.dumps(sites, indent=2))
    else:
        print(json.dumps({'sites': json.dumps(sites)}))


if __name__ == '__main__':
    main('--debug' in sys.argv)
