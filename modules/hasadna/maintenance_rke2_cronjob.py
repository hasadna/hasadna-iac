#!/usr/bin/env python3
import os
import json
import datetime
import subprocess


CLEANUP_OLD_LOGS_PATHS = [
    "airflow-home/logs",
    "ckan-dgp-logs/airflow-logs",
    "importer/geodata/logs",
    "airflow:logs"
]


def check_rke2_certificates():
    print("Checking RKE2 certificates...")
    for cert in json.loads(subprocess.check_output(["rke2", "certificate", "check", "--output", "json"]))["Certificates"]:
        expiry_time = cert["ExpiryTime"]  # 2035-05-22T09:35:09Z
        expiry_datetime = datetime.datetime.strptime(expiry_time, "%Y-%m-%dT%H:%M:%SZ")
        days_to_expiry = abs((expiry_datetime - datetime.datetime.now()).total_seconds()) / 60 / 60 / 24
        if days_to_expiry <= 14:
            print(f"{cert['Filename']} will expire in {days_to_expiry:.2f} days!")
            exit(1)
    print("All RKE2 certificates are valid.")


def cleanup_old_logs():
    cleaned_paths = 0
    for base_path in ["/export", "/mnt/storage", "/var/lib/kubelet/plugins/kubernetes.io/csi/rook-ceph.cephfs.csi.ceph.com"]:
        if os.path.exists(base_path):
            print(f"Cleaning up old logs under {base_path}...")
            subprocess.check_call([
                "/root/hasadna_k8s.sh", "storage", "cleanup-old-logs", base_path, *CLEANUP_OLD_LOGS_PATHS, "--no-dry-run"
            ])
            cleaned_paths += 1
    if cleaned_paths == 0:
        print("No paths found for cleanup.")
    else:
        print("Old logs cleanup completed.")


def update_heartbeat():
    print("Updating Heartbeat...")
    with open("/root/rke2_maintenance_heartbeat_url", "r") as f:
        heartbeat_url = f.read().strip()
    subprocess.check_call(["curl", heartbeat_url])
    print("Heartbeat updated successfully.")


def main():
    cleanup_old_logs()
    status, output = subprocess.getstatusoutput("which rke2")
    if status == 0:
        check_rke2_certificates()
    update_heartbeat()
    print("Great Success")


main()
