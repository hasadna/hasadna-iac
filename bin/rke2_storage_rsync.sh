#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="$1"
SOURCE_TYPE="$2"
SOURCE_PATH="$3"
TARGET_PVC="$4"
DEBUG="${5:-}"

if [ "${SOURCE_TYPE}" == "nfs" ]; then
  SOURCE_VOLUME_YAML='nfs: {server: 172.16.0.9, path: '${SOURCE_PATH}'}'
fi

if [ "${DEBUG}" == "" ]; then
  PODCMD="[rsync, -azh, --progress, --delete, --checksum, /source/, /target/]"
else
  PODCMD="[sleep, '999999999']"
fi

echo 'apiVersion: v1
kind: Pod
metadata:
  name: rke2-storage-rsyncer-'${TARGET_PVC}'
  namespace: '${NAMESPACE}'
spec:
  volumes:
  - name: source
    '${SOURCE_VOLUME_YAML}'
  - name: target
    persistentVolumeClaim:
      claimName: '${TARGET_PVC}'
  restartPolicy: Never
  containers:
    - name: rsyncer
      image: ghcr.io/hasadna/hasadna-k8s/hasadna-k8s:54a52cc7fc6aea95df743d916207a32ed714ce56
      volumeMounts:
        - name: source
          mountPath: /source
        - name: target
          mountPath: /target
      securityContext:
        privileged: true
        runAsUser: 0
      command: '${PODCMD}'
' | kubectl create -f -

echo waiting for pod to be running...
while true; do
  POD_STATUS="$(kubectl -n $NAMESPACE get pod "rke2-storage-rsyncer-${TARGET_PVC}" -o jsonpath='{.status.phase}')"
  echo POD_STATUS: "${POD_STATUS}"
  if [ "${POD_STATUS}" == "Running" ] || [ "${POD_STATUS}" == "Succeeded" ] || [ "${POD_STATUS}" == "Failed" ]; then
    break
  fi
  sleep 1
done

if [ "${DEBUG}" == "" ]; then
  kubectl -n $NAMESPACE logs "rke2-storage-rsyncer-${TARGET_PVC}" --follow
  EXITCODE="$(kubectl -n $NAMESPACE get pod "rke2-storage-rsyncer-${TARGET_PVC}" -o jsonpath='{.status.containerStatuses[0].state.terminated.exitCode}')"
  if [ "${EXITCODE}" != "0" ]; then
    echo "Rsync failed with exit code ${EXITCODE}"
  else
    echo "Rsync completed successfully"
  fi
else
  kubectl -n $NAMESPACE exec -it "rke2-storage-rsyncer-${TARGET_PVC}" -- bash
  EXITCODE=$?
fi
kubectl -n $NAMESPACE delete pod "rke2-storage-rsyncer-${TARGET_PVC}" --grace-period=1
exit "${EXITCODE}"
