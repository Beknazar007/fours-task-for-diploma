account_name                = "dev"
environment                 = "dev"
aws_region                  = "us-east-1"
vpc_name                    = "dev-vpc"
vpc_network_cidr            = "10.81.32.0/20"
resource_availability_zones = ["us-east-1a", "us-east-1b"]



############################################################################
#Cluster 1
##############################################################################
cluster_name                    = "cluster"
cluster_version                 = "1.27"
vpc_cni_version                 = "v1.15.0-eksbuild.2"
coredns_version                 = "v1.10.1-eksbuild.4"
kube-proxy_version              = "v1.27.1-eksbuild.1"
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = true
create_cloudwatch_log_group     = false
enable_irsa                     = true
node_groups_instance_types      = "t3.medium"
node_groups_capacity_type       = "ON_DEMAND"
node_groups_disk_size           = 50
node_groups_min_size            = 1
node_groups_max_size            = 8
node_groups_desired_size        = 2
cluster_security_group_additional_rules = {
  egress1 = {
    description                = "Allow the cluster control plane to communicate with pods running extension API servers on port 443"
    protocol                   = "TCP"
    from_port                  = 443
    to_port                    = 443
    type                       = "egress"
    source_node_security_group = true
  }
  egress2 = {
    description                = "Allow the cluster control plane to communicate with worker Kubelet and pods"
    protocol                   = "TCP"
    from_port                  = 1025
    to_port                    = 65535
    type                       = "egress"
    source_node_security_group = true
  }
}
node_security_group_additional_rules = {
  allow_nodes = {
    description = "Allow node to communicate with each other"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    type        = "ingress"
    self        = true
  }
  ingress_for_pods = {
    description                   = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
    protocol                      = "TCP"
    from_port                     = 443
    to_port                       = 443
    type                          = "ingress"
    source_cluster_security_group = true
  }
  ingress_ports_icmp = {
    protocol    = "ICMP"
    type        = "ingress"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress_rule = {
    protocol    = "-1"
    type        = "egress"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
################################################################################
#CNI IRSA
################################################################################
attach_vpc_cni_policy      = true
vpc_cni_enable_ipv6        = true
role_name_prefix           = "VPC-CNI-IRSA-1"
namespace_service_accounts = "kube-system:*"