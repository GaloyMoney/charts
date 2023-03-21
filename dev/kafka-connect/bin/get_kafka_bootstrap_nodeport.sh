#!/bin/bash
set -e

NODE_PORT=$(kubectl -n galoy-dev-kafka get svc kafka-kafka-nodeport-bootstrap -o 'go-template={{(index .spec.ports 0).nodePort}}')

while [ -z ${#NODE_PORT} ]; do
  echo "Waiting for service ${SERVICE_NAME} to become available..."
  sleep 10
  NODE_PORT=$(kubectl -n galoy-dev-kafka get svc kafka-kafka-nodeport-bootstrap -o 'go-template={{(index .spec.ports 0).nodePort}}')
done

echo "{\"result\": \"$NODE_PORT\"}"
