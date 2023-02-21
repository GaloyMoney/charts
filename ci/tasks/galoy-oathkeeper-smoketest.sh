#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

host=$(setting "galoy_endpoint")
port=$(setting "galoy_port")

phone=$(echo "$(setting "test_accounts")" | jq -r '.[0].phone')
code=$(echo "$(setting "test_accounts")" | jq -r '.[0].code')

function break_and_display_on_error_response() {
  if [[ $(jq -r '.errors' <./response.json) != "null" ]]; then
    echo Smoketest failed! - Response:
    cat response.json
    echo Contains "errors" key
    exit 1
  fi
}

# decline-direct-access-validatetoken
#"url": "<(http|https)>://<[a-zA-Z0-9-.:]+>/auth/validatetoken",
#"methods": ["GET", "POST"]
#unauthorized
set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl the decline-direct-access-validatetoken route"
  curl -LksS -X GET "${host}:${port}/auth/validatetoken" >response.json
  if grep Unauthorized >/dev/null <response.json; then
    success="true"
    break
  fi
  sleep 1
done
set -e

if ! grep Unauthorized >/dev/null <response.json; then
  echo Smoketest failed! - Response:
  cat response.json
  echo "Should be unauthorized"
  exit 1
fi

# apollo-playground-ui
#"url": "<(http|https)>://<[a-zA-Z0-9-.:]+>/graphql",
#"methods": ["GET", "OPTIONS"]
set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl the graphql route"
  curl -LksSf "${host}:${port}/graphql" \
    -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' \
    -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' \
    -H "Origin: ${host}:${port}" --data-binary \
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
#"url": "<(http|https)>://<[a-zA-Z0-9-.:]+>/graphql<.*>",
#"methods": [ "POST" ]
set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl the galoy-backend auth"
  curl -LksSf "${host}:${port}/graphql" -H 'Content-Type: application/json' \
    -H 'Accept: application/json' --data-binary \
    "{\"query\":\"mutation login(\$input: UserLoginInput!) { userLogin(input: \$input) { authToken } }\",\"variables\":{\"input\":{\"phone\":\"${phone}\",\"code\":\"${code}\"}}}" \
    >response.json
  if [[ $? == 0 ]]; then
    if grep "null" >/dev/null <response.json; then
      cat response.json
    else
      success="true"
      break
    fi
  fi
  sleep 1
done
set -e

break_and_display_on_error_response

# galoy-backend-middleware-routes
#"url": "<(http|https)>://<[a-zA-Z0-9-.:]+>/<(kratos|browser|healthz|metrics)(.*)>",
#"methods": ["GET", "POST", "OPTIONS"]
set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl the galoy-backend-middleware-routes"
  curl -LksSv -X GET "${host}:${port}/healthz" 2>response.json
  if grep "HTTP/1.1 200 OK" >/dev/null <response.json; then
    success="true"
    break
  fi
  sleep 1
done
set -e

if ! grep "HTTP/1.1 200 OK" >/dev/null <response.json; then
  echo Smoketest failed! - Response:
  cat response.json
  echo "Should be HTTP/1.1 200 OK"
  exit 1
fi

# admin-backend
#"url": "<(http|https)>://<.*><[0-9]*>/admin/<.*>",
#"methods": ["GET", "POST", "OPTIONS"]set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl the admin-backend route"
  curl -LksSf  "${host}:${port}/admin/graphql" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' --data-binary \
    "{\"query\":\"mutation login(\$input: UserLoginInput!) { userLogin(input: \$input) { authToken } }\",\"variables\":{\"input\":{\"phone\":\"${phone}\",\"code\":\"${code}\"}}}" \
    >response.json
  if [[ $? == 0 ]]; then
    if grep "null" >/dev/null <response.json; then
      cat response.json
    else
      success="true"
      break
    fi
  fi
  sleep 1
done
set -e

break_and_display_on_error_response
