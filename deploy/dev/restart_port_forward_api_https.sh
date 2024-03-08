#!/bin/bash

# Replace ${env} with your actual environment variable, or pass it as an argument to the script.

ENVIRONMENT="galoy-dev"
NAMESPACE="${ENVIRONMENT}-ingress"

while true; do
    echo "Starting kubectl port-forward..."
    kubectl -n $NAMESPACE port-forward --address 0.0.0.0 svc/ingress-nginx-controller 8080:443
    echo "kubectl port-forward has stopped. Restarting in 5 seconds..."
    sleep 5
done
