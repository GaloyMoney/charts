#!/bin/bash

# Replace ${env} with your actual environment variable, or pass it as an argument to the script.

ENVIRONMENT="galoy-dev"
NAMESPACE="${ENVIRONMENT}-galoy"

while true; do
    echo "Starting kubectl port-forward..."
    kubectl -n $NAMESPACE port-forward --address 0.0.0.0 pod/$(kubectl get pods -A  | grep websocket | awk '{print $2}') 4000:4000
    echo "kubectl port-forward has stopped. Restarting in 5 seconds..."
    sleep 5
done
