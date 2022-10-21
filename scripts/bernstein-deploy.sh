#echo nope
#exit 1

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
# $kubectl apply -f postgres.secret.yaml -f postgres.configmap.yaml -f postgres.volume.yaml -f postgres.deployment.yaml -f postgres.service.yaml

echo "[$(date)] kubectl: apply redis conf"
$kubectl apply -f redis.configmap.yaml \
-f redis.deployment.yaml \
-f redis.service.yaml
# $kubectl apply -f redis.configmap.yaml -f redis.deployment.yaml -f redis.service.yaml

echo "[$(date)] kubectl: apply redis conf"
$kubectl apply -f poll.deployment.yaml \
-f worker.deployment.yaml \
-f result.deployment.yaml \
-f poll.service.yaml \
-f result.service.yaml \
-f poll.ingress.yaml \
-f result.ingress.yaml
# $kubectl apply -f poll.deployment.yaml -f worker.deployment.yaml -f result.deployment.yaml -f poll.service.yaml -f result.service.yaml -f poll.ingress.yaml -f result.ingress.yaml

echo "[$(date)] kubectl: apply traefik conf"
$kubectl apply -f traefik.rbac.yaml \
-f traefik.deployment.yaml \
-f traefik.service.yaml
# $kubectl apply -f traefik.rbac.yaml -f traefik.deployment.yaml -f traefik.service.yaml

exit

echo "CREATE TABLE votes \
(id text PRIMARY KEY, vote text NOT NULL);" \
| $kubectl exec -i <postgres-deployment-id> -c <postgres-container-id> \
- psql -U username -P password
# echo "CREATE TABLE votes(id text PRIMARY KEY, vote text NOT NULL);" | $kubectl exec -i <postgres-deployment-id> -c <postgres-container-id> - psql -U <username>

echo "$($kubectl get nodes -o \
jsonpath='{ $.items[*].status.addresses[?(@.type=="ExternalIP")].address }') \
poll.dop.io result.dop.io" \
| sudo tee -a /etc/hosts
# echo "$($kubectl get nodes -o jsonpath='{ $.items[*].status.addresses[?(@.type=="ExternalIP")].address }') poll.dop.io result.dop.io" | sudo tee -a /etc/hosts
