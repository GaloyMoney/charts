TF:=terraform
REPO:=$(shell git rev-parse --show-toplevel)

create-cluster:
	k3d cluster create --image rancher/k3s:v1.23.14-k3s1 -v "$(REPO):/charts" \
					   --k3s-arg "--disable=traefik@server:0" \
					   --k3s-arg "--disable=servicelb@server:0"

delete-cluster:
	k3d cluster delete && rm terraform.tfstate

init:
	terraform init

deploy-services:
	$(TF) apply -target module.galoy_deps.helm_release.cert_manager \
				-var="bitcoin_network=regtest"	\
				-var="name_prefix=galoy-dev" -auto-approve
	$(TF) apply -target module.galoy_deps \
				-var="bitcoin_network=regtest" 	\
				-var="name_prefix=galoy-dev" -auto-approve

destroy-services:
	$(TF) destroy -var="bitcoin_network=regtest"	\
				-var="name_prefix=galoy-dev" -auto-approve

deploy-kafka-example:
	$(TF) apply -target module.kafka_example \
				-var="bitcoin_network=regtest" 	\
				-var="name_prefix=galoy-dev" -auto-approve

destroy-kafka-example:
	$(TF) destroy -target module.kafka_example \
				-var="bitcoin_network=regtest" 	\
				-var="name_prefix=galoy-dev" -auto-approve

deploy:
	$(TF) apply -var="bitcoin_network=regtest" \
				-var="name_prefix=galoy-dev" -auto-approve

all: create-cluster init deploy-services deploy

refresh:
	$(TF) refresh -var="bitcoin_network=regtest" \
				  -var="name_prefix=galoy-dev"
	$(TF) apply -var="bitcoin_network=regtest" \
				-var="name_prefix=galoy-dev" -auto-approve

redeploy-bitcoin:
	-kubectl delete namespace galoy-dev-bitcoin --force
	cd bitcoin
	$(TF) apply -target module.bitcoin -var="bitcoin_network=regtest" \
				-var="name_prefix=galoy-dev" -auto-approve

redeploy-galoy:
	-kubectl delete namespace galoy-dev-galoy --force
	cd galoy
	$(TF) apply -var="bitcoin_network=regtest" \
				-var="name_prefix=galoy-dev" -auto-approve

redeploy-monitoring:
	-kubectl delete namespace galoy-dev-monitoring --force
	cd monitoring
	$(TF) apply -var="bitcoin_network=regtest" \
				-var="name_prefix=galoy-dev" -auto-approve

redeploy-smoketest:
	-kubectl delete namespace galoy-dev-smoketest --force
	cd smoketest
	$(TF) apply -var="bitcoin_network=regtest" \
				-var="name_prefix=galoy-dev" -auto-approve


deploy-signet-services:
	$(TF) apply -target module.galoy_deps.helm_release.cert_manager \
				-var="bitcoin_network=signet" \
				-var="name_prefix=galoy-sig" -auto-approve
	$(TF) apply -target module.galoy_deps \
				-var="bitcoin_network=signet" \
				-var="name_prefix=galoy-sig" -auto-approve

deploy-signet:
	$(TF) apply -var="bitcoin_network=signet" \
				-var="name_prefix=galoy-sig" -auto-approve

all-signet: create-cluster init deploy-signet-services deploy-signet


redeploy-signet-bitcoin:
	-kubectl delete namespace galoy-sig-bitcoin --force
	cd bitcoin
	$(TF) apply -var="bitcoin_network=signet" \
				-var="name_prefix=galoy-sig" -auto-approve

redeploy-signet-galoy:
	-kubectl delete namespace galoy-sig-galoy --force
	cd galoy
	$(TF) apply -var="bitcoin_network=signet" \
				-var="name_prefix=galoy-sig" -auto-approve

redeploy-signet-addons:
	-kubectl delete namespace galoy-sig-addons --force
	cd addons
	$(TF) apply -var="name_prefix=galoy-sig" -auto-approve

redeploy-signet-monitoring:
	-kubectl delete namespace galoy-sig-monitoring --force
	cd monitoring
	$(TF) apply -var="bitcoin_network=signet" \
				-var="name_prefix=galoy-sig" -auto-approve


run-galoy-smoketest:
	kubectl -n galoy-dev-smoketest exec smoketest -- bash -c "cd /charts/ci/tasks && \
    CHART=galoy ./dev-smoketest-settings.sh && \
    ./galoy-smoketest.sh && \
    rm -rf smoketest-settings response.json"


fmt:
	cd ..
	$(TF) fmt -recursive

plan:
	$(TF) plan -var="bitcoin_network=regtest" -var="name_prefix=galoy-dev"

review:
	$(TF) show -json | jq

delete:
	kubectl delete namespace $(ns) --force

