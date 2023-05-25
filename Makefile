HELM_REPO=ghcr.io/austriandatalab/dbrepo # oci://
HELM_REPO_release=https://austriandatalab.github.io/dbrepo
APP_NAME=dbrepo
APP_NS=dbrepo
GITHUB_USERNAME=


.PHONY: all

all: clean build deploy install

clean:
	kubectl delete --all deployment --namespace=dbrepo

init:
	kubectl create namespace ${APP_NS}

build:
	helm package ./charts/dbrepo --destination ./build

deploy: build
	# Make sure GITHUB_TOKEN is in environment and is allowed to push packages to HELM_REPO
	@echo ${GITHUB_TOKEN} | helm registry login ${HELM_REPO} --username ${GH_USERNAME} --password-stdin
	helm push ./build/dbrepo-*.tgz oci://${HELM_REPO}/dbrepo-helm

install:
	helm upgrade --install ${APP_NAME} -n ${APP_NS} oci://${HELM_REPO}/dbrepo --create-namespace --cleanup-on-fail

install_release:
	helm repo add ${APP_NAME} ${HELM_REPO_release}
	helm repo update
	helm upgrade --install ${APP_NAME} -n ${APP_NS} ${APP_NS}/${APP_NAME} --create-namespace --cleanup-on-fail

values:
	helm upgrade --install ${APP_NAME} -n ${APP_NS} ${APP_NS}/${APP_NAME} --create-namespace --cleanup-on-fail --values charts/dbrepo/values.yaml