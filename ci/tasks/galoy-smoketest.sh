#!/bin/bash

namespace=${NAMESPACE:-$(cat testflight/env_name)}
host=graphql.${namespace}.svc.cluster.local

curl --location --request POST "${host}:4000/graphql"\
 --header 'Content-Type: application/json' \
 --data-raw '{"query":"query prices {\n    prices(length: 0) {\n        id\n        o\n    }\n}","variables":{}}'
