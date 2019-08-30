#!/usr/bin/env bash

export APP_INSTANCE_NAME=efk
export NAMESPACE=elastic
export ELASTICSEARCH_REPLICAS=1
export METRICS_EXPORTER_ENABLED=true
# this is the latest that Google offer it seems - 7.2 is out!
export TAG=6.3

kubectl create clusterrolebinding elastic-cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config list account --format "value(core.account)")

# install "application" CRD from Google
kubectl apply -f ./install/app-crd.yaml

kubectl apply -f ./install/namespace.yaml

export IMAGE_ELASTICSEARCH="marketplace.gcr.io/google/elastic-gke-logging:${TAG}"
export IMAGE_KIBANA="marketplace.gcr.io/google/elastic-gke-logging/kibana:${TAG}"
export IMAGE_FLUENTD="marketplace.gcr.io/google/elastic-gke-logging/fluentd:${TAG}"
export IMAGE_INIT="marketplace.gcr.io/google/elastic-gke-logging/ubuntu16_04:${TAG}"
export IMAGE_METRICS_EXPORTER="marketplace.gcr.io/google/elastic-gke-logging/prometheus-to-sd:${TAG}"

export FLUENTD_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-fluentdserviceaccount"
kubectl create serviceaccount ${FLUENTD_SERVICE_ACCOUNT} --namespace ${NAMESPACE}
kubectl create clusterrole ${FLUENTD_SERVICE_ACCOUNT}-role --verb=get,list,watch --resource=pods,namespaces
kubectl create clusterrolebinding ${FLUENTD_SERVICE_ACCOUNT}-rule --clusterrole=${FLUENTD_SERVICE_ACCOUNT}-role --serviceaccount=${NAMESPACE}:${FLUENTD_SERVICE_ACCOUNT}

echo ""
echo "Generating yaml from helm chart ..."

helm template chart --name ${APP_INSTANCE_NAME} \
                    --namespace ${NAMESPACE} \
                    --set elasticsearch.replicas=${ELASTICSEARCH_REPLICAS} \
                    --set fluentd.serviceAccount=${FLUENTD_SERVICE_ACCOUNT} \
                    --set initImage=${IMAGE_INIT} \
                    --set elasticsearch.image=${IMAGE_ELASTICSEARCH} \
                    --set kibana.image=${IMAGE_KIBANA} \
                    --set fluentd.image=${IMAGE_FLUENTD} \
                    --set metrics.image=${IMAGE_METRICS_EXPORTER} \
                    --set metrics.enabled=${METRICS_EXPORTER_ENABLED} > ./k8s/"${APP_INSTANCE_NAME}_manifest.yaml"

if [[ -f ./k8s/"${APP_INSTANCE_NAME}_manifest.yaml" ]]; then
  echo "./k8s/${APP_INSTANCE_NAME}_manifest.yaml generated"
else
  echo "[ERROR} Manifest was not created"
  exit 1
fi