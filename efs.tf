resource "aws_efs_file_system" "main" {
  tags = {
    Name = "${var.project}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(aws_subnet.private.*.id)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = element(aws_subnet.private.*.id, count.index)
  security_groups = ["${aws_security_group.efs.id}"]
}
