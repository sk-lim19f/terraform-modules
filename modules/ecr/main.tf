resource "aws_ecr_repository" "ecr_repository" {
  for_each = var.ecr_repository

  name                 = each.value.repository_name
  image_tag_mutability = each.value.mutability

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  for_each = var.ecr_lifecycle_policy

  repository = aws_ecr_repository.ecr_repository[each.value.ecr_key].name
  policy     = each.value.policy
}