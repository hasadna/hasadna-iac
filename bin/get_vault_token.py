#!/usr/bin/env python3
import os
import json
import subprocess


VAULT_ROLE_ID = os.getenv("VAULT_ROLE_ID")
VAULT_SECRET_ID = os.getenv("VAULT_SECRET_ID")


def main():
    res = json.loads(subprocess.check_output([
        "vault", "write", "auth/approle/login", f"role_id={VAULT_ROLE_ID}", f"secret_id={VAULT_SECRET_ID}",
        "-format=json"
    ]))
    print(res["auth"]["client_token"])


if __name__ == "__main__":
    main()
