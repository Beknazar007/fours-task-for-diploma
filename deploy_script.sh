#!/bin/bash

# Variables
IMAGE = "yeasy/simple-web"
NAMESPACE="default"
CERT_MANAGER_VERSION="v1.10.1"kube
EMAIL="saitovbeknazar6@gmail.com" # Replace with your email
DEPLOYMENT_NAME="simple-web"
SERVICE_NAME="simple-web-service"
INGRESS_NAME="simple-web-ingress"
CLUSTER_ISSUER_NAME="letsencrypt-prod"

# Apply deployment and service
cat <<EOF | kubectl apply -f -
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
  type: ClusterIP
EOF

# Install Cert-Manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.crds.yaml
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version $CERT_MANAGER_VERSION

# Create ClusterIssuer
cat <<EOF | kubectl apply -f -
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
EOF

# Install NGINX Ingress Controller
kubectl create namespace ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx

# Get the external IP of the Ingress Controller
EXTERNAL_IP=""
while [ -z $EXTERNAL_IP ]; do
  echo "Waiting for end point..."
  EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller --namespace ingress-nginx --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
  [ -z "$EXTERNAL_IP" ] && sleep 10
done
echo "End point ready: $EXTERNAL_IP"

# Create Ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $INGRESS_NAME
  annotations:
    cert-manager.io/cluster-issuer: "$CLUSTER_ISSUER_NAME"
spec:
  rules:
  - host: $EXTERNAL_IP.nip.io
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
    - $EXTERNAL_IP.nip.io
    secretName: simple-web-tls
EOF

echo "Deployment complete. Access your application at http://$EXTERNAL_IP.nip.io"
