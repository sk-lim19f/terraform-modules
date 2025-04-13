resource "aws_cognito_user_pool" "cognito_user_pool" {
  for_each = var.cognito_user_pool

  name = each.value.name

  schema {
    name                     = "email"
    attribute_data_type     = "String"
    required                = true
    mutable                 = true
    developer_only_attribute = false
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "cognito_user_pool_client" {
  for_each = var.cognito_user_pool_client

  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.cognito_user_pool[each.value.user_pool_key].id

  explicit_auth_flows = each.value.explicit_auth_flows

  generate_secret = each.value.generate_secret

  allowed_oauth_flows                  = each.value.allowed_oauth_flows
  allowed_oauth_scopes                 = each.value.allowed_oauth_scopes
  callback_urls                        = each.value.callback_urls
  logout_urls                          = each.value.logout_urls
  allowed_oauth_flows_user_pool_client = each.value.allowed_oauth_flows_user_pool_client

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "cognito_user_pool_domain" {
  for_each = var.cognito_user_pool_domain

  domain       = each.value.domain
  user_pool_id = aws_cognito_user_pool.cognito_user_pool[each.value.user_pool_key].id
}

resource "aws_cognito_user_group" "cognito_user_group" {
  for_each = var.cognito_user_group

  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.cognito_user_pool[each.value.user_pool_key].id
}
