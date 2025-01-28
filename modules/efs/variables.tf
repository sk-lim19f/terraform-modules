variable "environment" {
  type        = string
}

variable "efs" {
  type = map(object({
    tag_name = string
  }))
}

variable "mount_targets" {
  type = map(object({
    file_system_key = string
    security_groups = list(string)
    subnet_id       = string
  }))
}

variable "access_points" {
  type = map(object({
    file_system_key           = string
    posix_user_uid            = number
    posix_user_gid            = number
    root_directory_path       = string
    creation_info_owner_uid   = number
    creation_info_owner_gid   = number
    creation_info_permissions = string
    tags                      = map(string)
  }))
  default = {}
}
