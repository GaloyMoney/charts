#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

alertmanager_host=`setting "alertmanager_host"`

curl ${alertmanager_host}/-/healthy
