resource "aws_secretsmanager_secret" "secretsmanager_secret" {
  for_each = var.secretsmanager_secret

  name        = each.value.name
  description = each.value.description
}

resource "aws_secretsmanager_secret_version" "secretsmanager_secret_version" {
  for_each = var.secretsmanager_secret_version

  secret_id = aws_secretsmanager_secret.secretsmanager_secret[each.value.secretsmanager_secret_key].id
  secret_string = each.value.secret_string
}
