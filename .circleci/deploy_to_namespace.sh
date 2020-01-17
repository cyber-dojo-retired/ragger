#!/bin/bash -Eeu

echo The ragger service is now part of the runner service
exit 0

readonly NAMESPACE="${1}" # eg beta

# misc env-vars are in ci context

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
  --namespace=${NAMESPACE} \
  --set-string containers[0].tag=${CIRCLE_SHA1:0:7} \
  --values .circleci/ragger-values.yaml \
  --values .circleci/ragger-env-${NAMESPACE}.yaml \
  ${NAMESPACE}-ragger \
  praqma/cyber-dojo-service \
  --version 0.2.4
