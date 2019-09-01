#!/usr/bin/env bash

if [[ -z ${NAMESPACE} ]]; then echo "Must export NAMESPACE to deploy into"; exit 1; fi

kubectl apply -n=${NAMESPACE} -f ./k8s/storage-class.yaml

kubectl apply -n=${NAMESPACE} -f ./k8s/efk_manifest.yaml
