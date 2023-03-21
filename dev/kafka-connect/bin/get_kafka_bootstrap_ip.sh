#!/bin/bash
set -e

INTERNAL_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "{\"result\": \"$INTERNAL_IP\"}"
