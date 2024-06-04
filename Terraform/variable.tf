variable "account_name" {}

variable "environment" {}

variable "aws_region" {}

variable "vpc_name" {}

variable "vpc_network_cidr" {}

variable "resource_availability_zones" {
  type = list(string)
}





###############################################################################
#Cluster
###############################################################################
variable "cluster_name" {
  type        = string
  description = "  EKS cluster name"
}
variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
}
variable "vpc_cni_version" {
  description = "Kubernetes addons version to use for the EKS cluster (i.e.: `v1.15.0-eksbuild.2`)"
  type        = string
}
variable "coredns_version" {
  type        = string
  description = "Kubernetes addons version to use for the EKS cluster (i.e.: `v1.10.1-eksbuild.4`)"
}
variable "kube-proxy_version" {
  type        = string
  description = "Kubernetes addons version to use for the EKS cluster (i.e.: `v1.27.4-minimal-eksbuild.2`)"
}
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
}
variable "node_groups_instance_types" {
  type        = string
  description = "eks_managed_node_groups instance type"
}
variable "node_groups_disk_size" {

  type        = number
  description = "eks_managed_node_groups disk_size"
}
variable "node_groups_min_size" {
  type        = number
  description = "eks_managed_node_groups min_size"
}
variable "node_groups_max_size" {
  type        = number
  description = "eks_managed_node_groups max_size"
}
variable "node_groups_desired_size" {
  type        = number
  description = "eks_managed_node_groups desired_size"
}
variable "node_groups_capacity_type" {
  type        = string
  description = "eks_managed_node_groups capacity_type"
}
variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
}
variable "tags" {
  type = map(any)
  default = {
    Environment = ""
  }
}
################################################################################
# Cluster Security Group
################################################################################
variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
}
variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
}
################################################################################
# CloudWatch Log Group
################################################################################
variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
}
################################################################################
# CNI IRSA
################################################################################
variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
}
variable "attach_vpc_cni_policy" {
  description = "Determines whether to attach the VPC CNI IAM policy to the role"
  type        = bool
}
variable "vpc_cni_enable_ipv6" {
  description = "Determines whether to enable IPv6 permissions for VPC CNI policy"
  type        = bool
}
variable "oidc_providers" {
  description = "Map of OIDC providers where each provider map should contain the `provider`, `provider_arn`, and `namespace_service_accounts`"
  type        = any
  default     = {}
}
variable "namespace_service_accounts" {
  description = "A list of service accounts associated with namespaces"
  type        = any
}
variable "role_name_prefix" {
  description = "IAM role name prefix"
  type        = string
}
