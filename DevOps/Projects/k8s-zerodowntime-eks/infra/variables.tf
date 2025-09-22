variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  default = "aws-zerodowntime"
}

variable "enable_ingress" {
  description = "Install ingress-nginx via Helm"
  type        = bool
  default     = false
}


