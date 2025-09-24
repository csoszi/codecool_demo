output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_id
}

output "kubeconfig" {
  description = "Kubeconfig content (may be large). Use aws eks update-kubeconfig to populate local kubeconfig."
  value       = module.eks.kubeconfig
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "OIDC provider arn (if created)"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "todomvc_role_arn" {
  description = "IAM Role ARN for the todomvc service account (IRSA)"
  value       = aws_iam_role.todomvc_role.arn
}
