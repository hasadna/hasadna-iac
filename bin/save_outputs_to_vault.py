#!/usr/bin/env python3
import os
import json
import tempfile
import subprocess


def main():
    outputs = json.loads(subprocess.check_output(['terraform', 'output', '-json']))
    values = {k: v['value'] for k, v in outputs.items()}
    with tempfile.TemporaryDirectory() as tempdir:
        filename = os.path.join(tempdir, 'values.json')
        with open(filename, 'w') as f:
            json.dump(values, f)
        subprocess.check_call([
            'vault', 'kv', 'put', 'kv/Projects/iac/outputs', f'@{filename}'
        ])


if __name__ == "__main__":
    main()