#!/usr/bin/env bash
# 
# I quite like the kubectl plugin 'open-svc' (installed via krew) for this, but the below will work without it

KUBE_PROXY_PORT=8080

kubectl proxy -p ${KUBE_PROXY_PORT} &

sleep 1

NAMESPACE=elastic
APP_INSTANCE_NAME=efk

PROXY_BASE_URL=http://127.0.0.1:${KUBE_PROXY_PORT}/api/v1
ELASTIC_URL=${PROXY_BASE_URL}/namespaces/${NAMESPACE}/services/${APP_INSTANCE_NAME}-elasticsearch-svc:http/proxy/
KIBANA_URL=${PROXY_BASE_URL}/namespaces/${NAMESPACE}/services/${APP_INSTANCE_NAME}-kibana-svc:http/proxy/


curl ${ELASTIC_URL}

echo
echo "Elastic URL   :   ${ELASTIC_URL}"
echo

kubectl port-forward svc/efk-kibana-svc 5601:5601

echo "Kibana URL    :   http://localhost:5601/"
