variable "region" {
  type        = string
  default     = "us-west-2a"
  description = "AWS region to deploy to"
}

variable "subnet_ids" {
  type        = list(string)
  default     = ["subnet-123", "subnet-456"]
  description = "List of subnet IDs to deploy"
}

variable "eks_cluster_name" {
  type        = string
  default     = "eks-vault-lab"
  description = "Name of EKS Cluster"
}

variable "eks_node_group_name" {
  type        = string
  default     = "eks-vault-lab-node-group"
  description = "Name of EKS Node Group"
}

variable "eks_node_group_instance_type" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "Instance type of node group"
}

variable "eks_node_group_capacity_type" {
  type        = string
  default     = "SPOT"
  description = "Capacity type of node group"
}

variable "eks_iam_role_name" {
  type        = string
  default     = "eks-vault-lab-role"
  description = "Role attached to eks cluster"
}

variable "ec2_iam_role_name" {
  type        = string
  default     = "ec2-vault-lab-role"
  description = "Role attached to eks cluster"
}

variable "s3_storage_backend_name" {
  type        = string
  default     = "eks-vault-lab-s3-bucket"
  description = "description"
}

variable "storage_backend_iam_policy" {
  type        = string
  default     = "eks-vault-lab-s3-iam-policy"
  description = "description"
}
