resource "aws_efs_file_system" "shared_efs" {
  creation_token = "finally-animatronics-efs"

  tags = {
    Name = "finally-animatronics-efs"
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(data.terraform_remote_state.base.outputs.private_subnet_ids)

  file_system_id  = aws_efs_file_system.shared_efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_security_group" "efs_sg" {
  name        = "finally-animatronics-efs"
  description = "EFS access for EKS nodes"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  tags = {
    Name = "finally-animatronics-efs"
  }
}

resource "aws_security_group_rule" "efs_ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"

  security_group_id        = aws_security_group.efs_sg.id
  source_security_group_id = data.terraform_remote_state.base.outputs.node_security_group_id
}

resource "kubernetes_storage_class_v1" "efs_sc" {
  metadata {
    name = "efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.shared_efs.id
    directoryPerms   = "700"
  }
}