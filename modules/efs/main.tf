resource "aws_efs_file_system" "efs" {
  for_each = var.efs

  encrypted = true

  tags = {
    Name = each.value.tag_name
    ENV  = var.environment
  }
}

resource "aws_efs_mount_target" "mount_target" {
  for_each = var.mount_targets

  file_system_id  = aws_efs_file_system.efs[each.value.file_system_key].id
  security_groups = each.value.security_groups
  subnet_id       = each.value.subnet_id
}

resource "aws_efs_access_point" "access_points" {
  for_each = var.access_points

  file_system_id = aws_efs_file_system.efs[each.value.file_system_key].id

  posix_user {
    uid = each.value.posix_user_uid
    gid = each.value.posix_user_gid
  }

  root_directory {
    path = each.value.root_directory_path

    creation_info {
      owner_uid   = each.value.creation_info_owner_uid
      owner_gid   = each.value.creation_info_owner_gid
      permissions = each.value.creation_info_permissions
    }
  }

  tags = each.value.tags
}
