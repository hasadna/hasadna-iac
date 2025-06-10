#!/usr/bin/env python
import subprocess
import requests
import sys
import os

API_TOKEN = os.getenv("TF_VAR_cloudflare_api_token")
if not API_TOKEN:
    print("❌ TF_VAR_cloudflare_api_token environment variable is not set.")
    sys.exit(1)

HEADERS = {
    "Authorization": f"Bearer {API_TOKEN}",
    "Content-Type": "application/json"
}


def get_zone_id(zone_name):
    url = "https://api.cloudflare.com/client/v4/zones"
    params = {"name": zone_name}
    resp = requests.get(url, headers=HEADERS, params=params)
    data = resp.json()
    if not data["success"] or not data["result"]:
        raise Exception(f"Zone '{zone_name}' not found.")
    return data["result"][0]["id"]


def get_dns_records(zone_id, record_name):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    params = {"name": record_name}
    resp = requests.get(url, headers=HEADERS, params=params)
    data = resp.json()
    if not data["success"] or not data["result"]:
        raise Exception(f"DNS record '{record_name}' not found.")
    return data["result"]


def main():
    if len(sys.argv) != 5:
        print(f"Usage: {sys.argv[0]} <zone_name> <record_name/s> <tf_module_name> <tf_resource_name>")
        sys.exit(1)

    zone_name = sys.argv[1]
    record_name = sys.argv[2]
    tf_module_name = sys.argv[3]
    tf_resource_name = sys.argv[4]

    if ',' in record_name:
        for_each = True
        record_names = [r.strip().strip('"') for r in record_name.split(',') if r.strip().strip('"')]
    elif ' ' in record_name:
        for_each = True
        record_names = [r.strip() for r in record_name.split(' ') if r.strip()]
    else:
        for_each = False
        record_names = [record_name]

    for record_name in record_names:
        zone_id = get_zone_id(zone_name)
        records = get_dns_records(zone_id, f'{record_name}.{zone_name}' if record_name else zone_name)
        if len(records) == 1:
            record = records[0]
            record_id = record["id"]
            if for_each:
                cmd = f"terraform import 'module.{tf_module_name}.cloudflare_dns_record.{tf_resource_name}[\"{record_name}\"]' {zone_id}/{record_id}"
            else:
                cmd = f"terraform import 'module.{tf_module_name}.cloudflare_dns_record.{tf_resource_name}' {zone_id}/{record_id}"
            print(cmd)
            status, output = subprocess.getstatusoutput(cmd)
            if status != 0:
                print(f"❌ Error importing record '{record_name}': {output}")
            else:
                print(f"✅ Successfully imported record '{record_name}'.")
        elif len(records) > 1:
            print(f'found {len(records)} records for "{record_name}"')
            for record in records:
                print(f'{zone_id}/{record["id"]} - {record["content"]} ({record["type"]})')
        else:
            raise Exception(f"Record '{record_name}' not found.")



if __name__ == "__main__":
    main()
