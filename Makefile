HELM_REPO=oci://ghcr.io/martinweise/ui
APP_NAME=ui
APP_NS=dbrepo

.PHONY: all

all: clean build deploy install

clean:
	kubectl delete --all deployment --namespace=dbrepo

init:
	kubectl create namespace dbrepo

build:
	helm package ./kubernetes

deploy: build
	helm push ./ui-0.1.0.tgz oci://ghcr.io/martinweise

install:
	helm upgrade --install ${APP_NAME} -n ${APP_NS} ${HELM_REPO} --create-namespace --cleanup-on-fail