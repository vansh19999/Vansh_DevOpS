variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type        = string
  description = "Existing EKS cluster name from Stack 1 output"
}
