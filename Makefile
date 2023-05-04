.PHONY: all

all:

build:
	helm package ./kubernetes

install: build
	helm install kubernetes-latest kubernetes