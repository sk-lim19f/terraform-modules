resource "aws_ssm_parameter" "parameter" {
  for_each = var.parameter

  name             = each.value.name
  description      = each.value.description
  type             = each.value.type
  value_wo         = each.value.value
  value_wo_version = each.value.version
}
