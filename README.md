

---

# Kubernetes Deployment with SSL Termination at Load Balancer using Cert-Manager and NGINX Ingress

This script automates the deployment of a Kubernetes application with SSL termination at the Load Balancer level using Cert-Manager and NGINX Ingress Controller. The SSL certificates are issued and managed by Let's Encrypt via Cert-Manager.

## Prerequisites

- Kubernetes cluster with kubectl configured
- Helm installed
- Public domain name (or use a dynamic DNS service)
## Screenshots
EKS ec2 instances
![](./screenshots/eks-nodes.png)
all details of the instance
![](./screenshots/Screenshot%20(106).png)
all ready part of the app that I have deployed
![](./screenshots/Screenshot%20(107).png)
## Script Overview

The script performs the following tasks:

1. Deploys a sample application (todo_app) as a Kubernetes Deployment.
2. Creates a LoadBalancer type Service to expose the application externally.
3. Installs Cert-Manager in the `cert-manager` namespace.
4. Sets up a ClusterIssuer for Let's Encrypt certificate issuance.
5. Installs NGINX Ingress Controller in the `ingress-nginx` namespace.
6. Retrieves the external IP address of the Ingress Controller.
7. Creates an Ingress resource to route traffic to the application and enforce SSL redirection.

## Usage

1. Update the script variables in the script to match your configuration:

   - `IMAGE`: Docker image name of your application.
   - `EMAIL`: Your email address for Let's Encrypt certificate notifications.
   - `DEPLOYMENT_NAME`: Name of the Kubernetes Deployment.
   - `SERVICE_NAME`: Name of the Kubernetes Service.
   - `INGRESS_NAME`: Name of the Ingress resource.
   - `CLUSTER_ISSUER_NAME`: Name of the ClusterIssuer for Let's Encrypt.

2. Run the script:

   ```bash
   bash deploy_with_ssl.sh
   ```

3. Wait for the script to complete. It will provide the external IP address of the Ingress Controller and the URL to access your application over HTTPS.

## Notes

- Ensure that your DNS records are correctly configured to point to the external IP address of the Ingress Controller.
- The script assumes the use of NGINX Ingress Controller. Modify the annotations accordingly if you use a different Ingress Controller.

---
