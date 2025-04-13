resource "aws_dynamodb_table" "dynamodb_table" {
  for_each = var.dynamodb_table

  name         = each.value.table_name
  billing_mode = each.value.billing_mode

  hash_key  = each.value.hash_key
  range_key = each.value.range_key

  dynamic "attribute" {
    for_each = each.value.attribute

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = each.value.global_secondary_index != null ? [each.value.global_secondary_index] : []

    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      projection_type = global_secondary_index.value.projection_type
    }
  }
}
