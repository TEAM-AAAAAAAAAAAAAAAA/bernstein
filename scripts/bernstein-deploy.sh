#!/usr/bin/env bash

# minikube start -p bernstein
# minikube kubectl config use-context bernstein

if [[ "$EUID" -ne 0 && -z "$CI" ]]; then
    echo "please run this script as root"
    exit 1
fi

command_found() {
    command -v "$1" >/dev/null 2>&1
}

if command_found kubectl; then
    kubectl=kubectl
elif command_found minikube; then
    kubectl="minikube kubectl --"
elif [ -x ./minikube ]; then
    kubectl="./minikube kubectl --"
else
    echo "kubectl: command not found"
    exit 1
fi

echo "[$(date)] kubectl: apply cadvisor conf"
$kubectl apply -f cadvisor.daemonset.yaml

echo "[$(date)] kubectl: apply postgres conf"
$kubectl apply -f postgres.secret.yaml \
-f postgres.configmap.yaml \
-f postgres.volume.yaml \
-f postgres.deployment.yaml \
-f postgres.service.yaml

echo "[$(date)] kubectl: apply redis conf"
$kubectl apply -f redis.configmap.yaml \
-f redis.deployment.yaml \
-f redis.service.yaml

echo "[$(date)] kubectl: apply redis conf"
$kubectl apply -f poll.deployment.yaml \
-f worker.deployment.yaml \
-f result.deployment.yaml \
-f poll.service.yaml \
-f result.service.yaml \
-f poll.ingress.yaml \
-f result.ingress.yaml

echo "[$(date)] kubectl: apply traefik conf"
$kubectl apply -f traefik.rbac.yaml \
-f traefik.deployment.yaml \
-f traefik.service.yaml

echo "[$(date)] kubectl: create postgres table"
pg_deploy_id_pattern="kube-deploy-postgres-*-*"
pg_deploy_id=$($kubectl get pods -o json | jq -r '.items[]|select(.metadata.name|test("$pg_deploy_id_pattern")).metadata.name')
psql_username=username
psql_password=password

#echo "$pg_deploy_id_pattern"
#echo "$pg_deploy_id"
#echo "$psql_username"
#echo "$psql_password"

# debug
echo version: $(psql --version)
echo U flag: $(psql --help | grep -w -- -U || true)
echo "CREATE TABLE IF NOT EXISTS votes(id text PRIMARY KEY, vote text NOT NULL);" \
| $kubectl exec -i $pg_deploy_id - psql -U $psql_username -P $psql_password

if [[ -z "${CI}" ]]; then
    echo "[$(date)] system: *.dop.io IPs mapping"
    echo "$($kubectl get nodes -o \
    jsonpath='{ $.items[*].status.addresses[?(@.type=="ExternalIP")].address }') poll.dop.io result.dop.io" \
    | sudo tee -a /etc/hosts
fi
