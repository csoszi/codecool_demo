locals {
  create_vpc = length(var.subnet_ids) == 0 || var.vpc_id == "" ? true : false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = ">= 19.0.0" # adjust per your required version
  cluster_name    = var.cluster_name
  cluster_version = "1.30" # pick a supported Kubernetes version

  # If you want module to create VPC, leave vpc_id empty — otherwise provide vpc_id & subnet_ids
  vpc_id     = var.vpc_id != "" ? var.vpc_id : null
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : null

  eks_managed_node_groups = {
    default = {
      desired_capacity = var.node_desired_capacity
      max_capacity     = var.node_desired_capacity + 1
      min_capacity     = 1
      instance_types   = var.node_instance_types
    }
  }

  # enable IAM OIDC
  manage_aws_auth = true
}

# ---- Create OIDC provider if not created by module (some module versions manage it automatically) ----
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

# ---- Example IAM Role for ServiceAccount (IRSA) ----
resource "aws_iam_role" "todomvc_role" {
  name = "${var.cluster_name}-todomvc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # The sub condition ties the role to serviceaccount "todomvc-sa" in the default namespace.
            "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:default:todomvc-sa"
          }
        }
      }
    ]
  })
}

# Attach a sample policy (S3 ReadOnly) — modify according to needs
resource "aws_iam_role_policy_attachment" "todomvc_s3_read" {
  role       = aws_iam_role.todomvc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
