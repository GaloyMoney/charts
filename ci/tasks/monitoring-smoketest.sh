#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

grafana_host=`setting "grafana_host"`

curl ${grafana_host}
