variable "environment" {
  description = "Deployment environment (dev, sit, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for provisioning"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs for multi-AZ high availability"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "min_nodes" {
  description = "Minimum node count for autoscaling group"
  type        = number
  default     = 3
}

variable "max_nodes" {
  description = "Maximum node count for autoscaling group"
  type        = number
  default     = 10
}
