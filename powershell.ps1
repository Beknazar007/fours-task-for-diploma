# Variables
$IMAGE = "beknazar007/todo_app:latest"
$NAMESPACE = "default"
$CERT_MANAGER_VERSION = "v1.14.5"
$EMAIL = "saitovbeknazar6@gmail.com" # Replace with your email
$DEPLOYMENT_NAME = "beknazar007-todo-app"
$SERVICE_NAME = "beknazar007-todo-app-service"
$INGRESS_NAME = "beknazar007-todo-app-ingress"
$CLUSTER_ISSUER_NAME = "letsencrypt-prod"

# Apply deployment and service
@"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT_NAME
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $DEPLOYMENT_NAME
  template:
    metadata:
      labels:
        app: $DEPLOYMENT_NAME
    spec:
      containers:
      - name: $DEPLOYMENT_NAME
        image: $IMAGE
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME
spec:
  selector:
    app: $DEPLOYMENT_NAME
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
"@ | kubectl apply -f -

# Install Cert-Manager
kubectl apply -f "https://github.com/jetstack/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.crds.yaml"
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version $CERT_MANAGER_VERSION

# Create ClusterIssuer
@"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: $CLUSTER_ISSUER_NAME
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $EMAIL
    privateKeySecretRef:
      name: $CLUSTER_ISSUER_NAME
    solvers:
    - http01:
        ingress:
          class: nginx
"@ | kubectl apply -f -

# Install NGINX Ingress Controller
kubectl create namespace ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx

# Get the external IP of the Ingress Controller
$EXTERNAL_IP = ""
while ($EXTERNAL_IP -eq "") {
  Write-Host "Waiting for end point..."
  $EXTERNAL_IP = kubectl get svc ingress-nginx-controller --namespace ingress-nginx --output jsonpath="{.status.loadBalancer.ingress[0].ip}{.status.loadBalancer.ingress[0].hostname}"
  if ($EXTERNAL_IP -eq "") { Start-Sleep -Seconds 10 }
}
Write-Host "End point ready: $EXTERNAL_IP"

# Create Ingress
@"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $INGRESS_NAME
  annotations:
    cert-manager.io/cluster-issuer: "$CLUSTER_ISSUER_NAME"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"  
spec:
  rules:
  - host: $EXTERNAL_IP
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $SERVICE_NAME
            port:
              number: 80
  tls:
  - hosts:
    - $EXTERNAL_IP
    secretName: ""
"@ | kubectl apply -f -

Write-Host "Deployment complete. Access your application at http://$EXTERNAL_IP"
