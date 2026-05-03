# variable "kubeconfig_path" {
#   description = "Path to the kubeconfig file"
#   type        = string
#   default     = "~/.kube/config"
# }

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-1" 

  validation {
    condition     = can(regex("^us-|^eu-|^ap-", var.region))
    error_message = "Region must be a valid AWS region string."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile name used for authentication"
  type        = string
  default     = "Administrator-450287579526"

  validation {
    condition     = length(var.aws_profile) > 0
    error_message = "aws_profile cannot be empty."
  }
}