TF:=terraform

create-cluster:
	k3d cluster create --k3s-arg "--disable=traefik@server:0" --k3s-arg "--disable=servicelb@server:0"

delete-cluster:
	k3d cluster delete && rm terraform.tfstate

init:
	terraform init

deploy-services:
	$(TF) apply -target module.infra_services.helm_release.cert_manager -auto-approve
	$(TF) apply -target module.infra_services -auto-approve

deploy:
	$(TF) apply -auto-approve

fmt:
	$(TF) fmt -recursive

all: create-cluster init deploy-services deploy
