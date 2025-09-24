variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
  default     = "todomvc-cluster"
}

variable "vpc_id" {
  description = "VPC id to launch EKS in (if empty, module can create a vpc)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs to use for EKS (if provided)"
  type        = list(string)
  default     = []
}

variable "node_instance_types" {
  description = "EC2 instance types for managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_capacity" {
  description = "Managed node group desired size"
  type        = number
  default     = 2
}
