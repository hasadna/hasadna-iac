#!/usr/bin/env python3
import os
import json
import tempfile
import subprocess


def set_values(path_part, values):
    with tempfile.TemporaryDirectory() as tempdir:
        filename = os.path.join(tempdir, 'values.json')
        with open(filename, 'w') as f:
            json.dump(values, f)
        subprocess.check_call([
            'vault', 'kv', 'put', f'kv/Projects/iac/outputs/{path_part}', f'@{filename}'
        ])


def set_values_startswith(values, path_part, startswith=None):
    if startswith is None:
        startswith = path_part
    set_values(path_part, {
        k.replace(startswith, '').strip().strip('_'): v
        for k, v
        in values.items() if k.startswith(startswith)
    })


def main():
    outputs = json.loads(subprocess.check_output(['terraform', 'output', '-json']))
    values = {k: v['value'] for k, v in outputs.items()}
    set_values_startswith(values, 'hasadna_ssh_access_point')
    set_values_startswith(values, 'hasadna_argoevents')
    set_values_startswith(values, 'hasadna_argocd')


if __name__ == "__main__":
    main()
