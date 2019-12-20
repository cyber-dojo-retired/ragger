#!/bin/bash
set -e

# misc env-vars are in ci context
echo "arg1=:${1}:"
echo "CIRCLE_SHA1=:${CIRCLE_SHA1}:"
exit 42

echo ${GCP_K8S_CREDENTIALS} > /gcp/gcp-credentials.json

gcloud auth activate-service-account \
  "${SERVICE_ACCOUNT}" \
  --key-file=/gcp/gcp-credentials.json
gcloud container clusters get-credentials \
  "${CLUSTER}" \
  --zone "${ZONE}" \
  --project "${PROJECT}"

helm init --client-only
helm repo add praqma https://praqma-helm-repo.s3.amazonaws.com/
helm upgrade \
  --install \
  --namespace=beta \
  --set-string containers[0].tag=${CIRCLE_SHA1:0:7} \
  --values .circleci/ragger-values.yaml \
  --values .circleci/ragger-env-beta.yaml \
  beta-ragger \
  praqma/cyber-dojo-service \
  --version 0.2.4
