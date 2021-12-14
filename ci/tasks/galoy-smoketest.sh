#!/bin/bash

source smoketest-settings/helpers.sh

host=`setting "galoy_endpoint"`
port=`setting "galoy_port"`

curl --location --request POST "${host}:${port}/graphql"\
 --header 'Content-Type: application/json' \
 --data-raw '{"query":"query prices {\n    prices(length: 0) {\n        id\n        o\n    }\n}","variables":{}}' > response.json

if [[ $(cat ./response.json | jq -r '.errors') != "null" ]]; then
  echo Testflight failed! - Response:
  cat response.json
  echo Contains "errors" key
  exit 1
fi

if [[ `setting_exists "smoketest_kubeconfig"` != "null" ]]; then
  setting "smoketest_kubeconfig" | base64 --decode > kubeconfig.json
  export KUBECONFIG=$(pwd)/kubeconfig.json
  namespace=`setting "galoy_namespace"`
  job_name="${namespace}-cronjob-smoketest"
  kubectl -n ${namespace} delete job "${job_name}" || true
  echo "Executing cronjob"
  kubectl -n ${namespace} create job --from=cronjob/cronjob "${job_name}"
  for i in {1..10}; do
    kubectl -n ${namespace}  wait --for=condition=complete job "${job_name}"
    if [[ $? -eq 0 ]]; then
      echo "Cronjob execution completed"
      break
    fi
    sleep 1
  done
  status="$(kubectl -n ${namespace} get job ${job_name} -o jsonpath='{.status.succeeded}')"
  if [[ "${status}" != "1" ]]; then
    echo "Cronjob failed!"
    exit 1
  else
    echo "Cronjob succeeded!"
  fi
  kubectl -n ${namespace} delete job "${job_name}"
fi
