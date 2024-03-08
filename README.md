# Flash DevOps

The Flash backend is run on Kubernetes using [Helm](https://github.com/helm/helm) and  [Terraform](https://www.terraform.io/). This is fork of the [Galoy Charts](https://github.com/GaloyMoney/charts), but heavily modified as we do not run the bitcoin/lightning infrastructure ourselves.

## Before you begin

### Setup a Kubernetes Cluster

This setup has been tested on DigitalOcean. Reference the ([`galoy-infra`](https://github.com/GaloyMoney/galoy-infra)) as a IaaS-based reference for using Google Cloud Platform (GCP).


### Install Helm
[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.
