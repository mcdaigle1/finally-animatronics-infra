terraform {
  required_version = ">= 1.6"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.43"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "~> 3.1"
    # }

    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "~> 3.1"
    # }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

# provider "kubernetes" {
#   config_path = var.kubeconfig_path
# }

# provider "helm" {
#   kubernetes = {
#     config_path = var.kubeconfig_path
#   }
# }

# data "aws_eks_cluster" "this" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "this" {
#   name = module.eks.cluster_name
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.this.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.this.token
# }

# provider "helm" {
#   kubernetes = {
#     host                   = data.aws_eks_cluster.this.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.this.token
#   }
# }

# variable "region" {
#   description = "The AWS region to deploy resources in"
#   type        = string
#   default     = "us-west-1"

#   validation {
#     condition     = can(regex("^us-|^eu-|^ap-", var.region))
#     error_message = "Region must be a valid AWS region string."
#   }
# }

# variable "aws_profile" {
#   description = "AWS CLI profile name used for authentication"
#   type        = string
#   default     = "Administrator-450287579526"

#   validation {
#     condition     = length(var.aws_profile) > 0
#     error_message = "aws_profile cannot be empty."
#   }
# }