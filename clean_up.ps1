# Variables
$NAMESPACE = "default"
$DEPLOYMENT_NAME = "beknazar007-todo-app"
$SERVICE_NAME = "beknazar007-todo-app-service"
$INGRESS_NAME = "beknazar007-todo-app-ingress"
$CLUSTER_ISSUER_NAME = "letsencrypt-prod"
$CERT_MANAGER_NAMESPACE = "cert-manager"
$INGRESS_NAMESPACE = "ingress-nginx"
$CERT_MANAGER_VERSION = "v1.10.1"

# Delete Ingress
kubectl delete ingress $INGRESS_NAME --namespace $NAMESPACE

# Delete Deployment
kubectl delete deployment $DEPLOYMENT_NAME --namespace $NAMESPACE

# Delete Service
kubectl delete service $SERVICE_NAME --namespace $NAMESPACE

# Delete ClusterIssuer
kubectl delete clusterissuer $CLUSTER_ISSUER_NAME

# Uninstall Cert-Manager
helm uninstall cert-manager --namespace $CERT_MANAGER_NAMESPACE
kubectl delete namespace $CERT_MANAGER_NAMESPACE

# Uninstall NGINX Ingress Controller
helm uninstall ingress-nginx --namespace $INGRESS_NAMESPACE
kubectl delete namespace $INGRESS_NAMESPACE

Write-Host "All resources have been cleaned up."
