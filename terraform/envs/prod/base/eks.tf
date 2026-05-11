resource "aws_iam_role" "efs_csi_driver" {
  name = "finally-anim-efs-csi-driver"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.oidc_provider, "https://", "")}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
          "${replace(module.eks.oidc_provider, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  role       = aws_iam_role.efs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

resource "aws_eks_addon" "efs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-efs-csi-driver"
  service_account_role_arn = aws_iam_role.efs_csi_driver.arn

  depends_on = [
    aws_iam_role_policy_attachment.efs_csi_driver
  ]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "finally-anim-eks"
  kubernetes_version = "1.35"

  create_iam_role = true

  enable_irsa = true

  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns = {}

    "kube-proxy" = {}

    "vpc-cni" = {
      before_compute = true
    }

    "eks-pod-identity-agent" = {
      before_compute = true
    }
  }

  vpc_id     = aws_vpc.finally_animatronics_vpc.id
  subnet_ids = aws_subnet.finally_animatronics_private_subnet[*].id

  eks_managed_node_groups = {
    general = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      desired_size = 2
      min_size     = 2
      max_size     = 3

      node_role_arn = aws_iam_role.eks_node_role.arn
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# resource "null_resource" "generate_kubeconfig" {
#   depends_on = [module.eks]

#   provisioner "local-exec" {
#     command = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
#   }
# }