resource "aws_efs_file_system" "shared_efs" {
  creation_token = "finally-animatronics-efs"

  tags = {
    Name = "finally-animatronics-efs"
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = {
    for subnet in aws_subnet.private :
    subnet.id => subnet
  }

  file_system_id  = aws_efs_file_system.shared_efs.id
  subnet_id       = each.value.id
  security_groups = [aws_security_group.efs.id]
}

resource "kubernetes_storage_class_v1" "efs_sc" {
  metadata {
    name = "efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.shared.id
    directoryPerms   = "700"
  }
}