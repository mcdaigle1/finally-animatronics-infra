provider "aws" {
  region = "us-west-1"
  profile = "Administrator-450287579526"
}

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.43"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"  # or latest stable version
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
  }
}

data "aws_eks_cluster" "this" {
  name = data.terraform_remote_state.base.outputs.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.base.outputs.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}