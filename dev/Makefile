TF:=terraform

create-cluster:
	k3d cluster create --k3s-server-arg '--no-deploy=traefik'

init:
	terraform init

deploy-services:
	$(TF) apply -target module.infra_services.helm_release.cert_manager -auto-approve
	$(TF) apply -target module.infra_services -auto-approve

deploy:
	$(TF) apply -auto-approve

fmt:
	$(TF) fmt -recursive
