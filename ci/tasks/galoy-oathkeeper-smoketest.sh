#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

host=$(setting "galoy_endpoint")
port=$(setting "galoy_port")

function break_and_display_on_error_response() {
  if [[ $(jq -r '.errors' <./response.json) != "null" ]]; then
    echo Smoketest failed! - Response:
    cat response.json
    echo Contains "errors" key
    exit 1
  fi
}

# decline-direct-access-validatetoken
#${host}:${port}/auth/validatetoken
#GET
#unauthorized
set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl the decline-direct-access-validatetoken route"
  curl -LksS -X GET "${host}:${port}/auth/validatetoken" >response.json
  if grep Unauthorized <response.json; then
    success="true"
    break
  fi
  sleep 1
done
set -e

if ! grep Unauthorized <response.json; then
  echo Smoketest failed! - Response:
  cat response.json
  echo "Should be unauthorized"
  exit 1
fi

# apollo-playground-ui
#${host}:${port}/graphql
#GET
set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl the graphql route"
  curl -LksSf "${host}:${port}/graphql" \
    -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' \
    -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' \
    -H 'Origin: ${host}:${port}' --data-binary \
    '{"query":"query btcPrice {\n btcPrice {\n base\n currencyUnit\n formattedAmount\n offset\n }\n }","variables":{}}' \
    >response.json

  if [[ $? == 0 ]]; then
    success="true"
    break
  fi
  sleep 1
done
set -e

break_and_display_on_error_response

# galoy-backend auth
#${host}:${port}/graphql<.*>
#POST
set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl the galoy-backend auth"
  curl -LksSf "${host}:${port}/graphql" -H 'Content-Type: application/json' \
    -H 'Accept: application/json' --data-binary \
    '{"query":"mutation login($input: UserLoginInput!) { userLogin(input: $input) { authToken } }","variables":{"input":{"phone":"+59981730222","code":"111111"}}}'
  if [[ $? == 0 ]]; then
    success="true"
    break
  fi
  sleep 1
done
set -e

break_and_display_on_error_response
