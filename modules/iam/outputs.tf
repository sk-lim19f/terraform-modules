output "role_arns" {
  value = { for k, iam_role in aws_iam_role.iam_role : k => iam_role.arn }
}

output "role_name" {
  value = { for k, iam_role in aws_iam_role.iam_role : k => iam_role.name }
}
