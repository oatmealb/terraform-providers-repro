module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.24.1"

  cluster_name    = var.cluster_name
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3a.micro"]
      capacity_type  = "SPOT"
    }
  }
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles            = var.aws_auth_roles
  aws_auth_users            = []
  aws_auth_accounts         = var.aws_auth_accounts
}