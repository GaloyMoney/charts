# Galoy Kubernetes Helm Charts

Galoy community banking application, launchable on Kubernetes using [Kubernetes Helm](https://github.com/helm/helm).

## Before you begin

### Setup a Kubernetes Cluster

These charts have been tested for GCP's [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/).

### Install Helm
[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

## What's included

This repo includes charts for:
- [`galoy`](https://github.com/GaloyMoney/galoy) Our bitcoin banking application

- [`bitcoind`](https://github.com/bitcoin/bitcoin) Bitcoin full node

- [`lnd`](https://github.com/lightningnetwork/lnd) Lightning Network daemon & client

- [`rtl`](https://github.com/Ride-The-Lightning/RTL) Dashboard for using `lnd`

- [`specter`](https://github.com/cryptoadvance/specter-desktop) On-chain wallet and multisig co-ordinator

- `monitoring` Metrics dashboard using [`grafana`](https://github.com/grafana/grafana) and [`prometheus`](https://github.com/prometheus/prometheus)
