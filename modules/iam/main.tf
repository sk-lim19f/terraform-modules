resource "aws_iam_role" "iam_role" {
  for_each = var.iam_role

  name = each.value.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "${each.value.service}.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  for_each = var.iam_instance_profile

  name = each.value.name
  role = aws_iam_role.iam_role[each.value.role_key].name
}

resource "aws_iam_policy" "iam_policy" {
  for_each = var.iam_policy

  name   = each.value.name
  policy = each.value.policy

  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  for_each = var.iam_role_policy_attachment

  role       = aws_iam_role.iam_role[each.value.role_key].name
  policy_arn = each.value.policy_key != null ? aws_iam_policy.iam_policy[each.value.policy_key].arn : each.value.policy_arn
}
