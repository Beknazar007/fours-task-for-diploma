
module "eks" {
  source                          = "./eks"
  cluster_name                    = "${var.environment}-${var.cluster_name}"
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  create_cloudwatch_log_group     = var.create_cloudwatch_log_group
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = [module.vpc.eks_subnet[0], module.vpc.eks_subnet[1]]
  enable_irsa                     = var.enable_irsa
  cluster_addons = {
    coredns = {
      addon_version = var.coredns_version
    }
    kube-proxy = {
      addon_version = var.kube-proxy_version
    }
    vpc-cni = {
      addon_version = var.vpc_cni_version
    }
  }
  eks_managed_node_groups = {
    managed_node_group = {
      name                       = "${var.environment}-${var.cluster_name}"
      create_launch_template     = true
      use_custom_launch_template = true
      disk_size                  = var.node_groups_disk_size
      min_size                   = var.node_groups_min_size
      max_size                   = var.node_groups_max_size
      desired_size               = var.node_groups_desired_size
      instance_types             = ["${var.node_groups_instance_types}"]
      capacity_type              = var.node_groups_capacity_type
      subnet_ids                 = ["${module.vpc.eks_subnet[0]}"]
    }
  }
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  node_security_group_additional_rules    = var.node_security_group_additional_rules

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

module "vpc_cni_irsa" {
  source                = "./iam-sa"
  role_name             = var.role_name_prefix
  attach_vpc_cni_policy = var.attach_vpc_cni_policy
  vpc_cni_enable_ipv6   = var.vpc_cni_enable_ipv6
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace_service_accounts}"]
    }
  }
}