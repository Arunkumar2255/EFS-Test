resource "aws_efs_file_system" "main" {
  creation_token = "my-efs"
  encrypted      = true
  tags           = merge({
    Name = "main-efs"
  }, var.tags)
}

resource "aws_security_group" "efs_sg" {
  name_prefix = "efs-sg-"
  vpc_id      = var.vpc_id
  tags        = merge({
    Name = "efs-sg"
  }, var.tags)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_efs_mount_target" "main" {
  count          = length(var.subnet_ids)
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_backup_policy" "main" {
  file_system_id = aws_efs_file_system.main.id
  backup_policy {
    status = "ENABLED"
  }
}
