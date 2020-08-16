resource "aws_efs_file_system" "efs" {
  creation_token = "laravel"
  performance_mode = "generalPurpose"

  tags = {
    Name = "laravel_efs"
  }
}

resource "aws_efs_mount_target" "laravel_mount" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.front_private.*.id
}