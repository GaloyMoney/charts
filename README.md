# Galoy Kubernetes Helm Charts

Galoy community banking application, launchable on Kubernetes using [Kubernetes Helm](https://github.com/helm/helm).

## Before you begin

### Setup a Kubernetes Cluster

These charts have been tested on top of the galoy infrastructure ([`galoy-infra`](https://github.com/GaloyMoney/galoy-infra)).

### Install Helm
[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

## What's included

This repo includes charts for:
- [`galoy`](https://github.com/GaloyMoney/galoy) Our bitcoin banking application
  - [`galoy-pay`](https://github.com/GaloyMoney/galoy-pay)
  - [`admin-panel`](https://github.com/GaloyMoney/admin-panel)
  - [`price`](https://github.com/GaloyMoney/price)

- [`bitcoind`](https://github.com/bitcoin/bitcoin) Bitcoin full node

- [`lnd`](https://github.com/lightningnetwork/lnd) Lightning Network daemon & client

- [`rtl`](https://github.com/Ride-The-Lightning/RTL) Dashboard for using `lnd`

- `monitoring` Metrics dashboard
  - [`grafana`](https://github.com/grafana/grafana)
  - [`prometheus`](https://github.com/prometheus/prometheus)
