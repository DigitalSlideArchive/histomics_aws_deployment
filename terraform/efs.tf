resource "aws_efs_file_system" "assetstore" {
}

resource "aws_security_group" "efs_mount_target_sg" {
  name = "efs-mount-target-sg"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create one mount target per subnet
resource "aws_efs_mount_target" "targets" {
  for_each = toset(data.aws_subnets.default.ids)

  file_system_id = aws_efs_file_system.assetstore.id
  subnet_id      = each.key

  security_groups = [aws_security_group.efs_mount_target_sg.id]
}
