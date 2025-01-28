output "efs_ids" {
  value       = { for k, efs in aws_efs_file_system.efs : k => efs.id }
}

output "ops_efs_id" {
  value = aws_efs_file_system.efs["ops_efs"].id
}

output "access_point_ids" {
  value       = { for k, access_point in aws_efs_access_point.access_points : k => access_point.id }
}
