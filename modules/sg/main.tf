resource "aws_security_group" "sg" {
  for_each = var.sg_configs

  name = join("-", compact([
    try(var.environment, null),
    lookup(each.value, "product", ""),
    lookup(each.value, "service", ""),
    lookup(each.value, "resource", "ec2"),
    "SG"
  ]))
  description = join("-", compact([
    var.environment,
    lookup(each.value, "product", ""),
    lookup(each.value, "service", ""),
    lookup(each.value, "resource", "ec2"),
    "SG"
  ]))
  vpc_id = var.vpc_id

  tags = merge(
    {
      name = join("-", compact([
        var.environment,
        lookup(each.value, "product", ""),
        lookup(each.value, "service", ""),
        lookup(each.value, "resource", "ec2"),
        "SG"
      ]))
      Environment = var.environment
    },
    length(lookup(each.value, "product", "")) > 0 ? { Product = each.value.product } : {},
    length(lookup(each.value, "service", "")) > 0 ? { Service = each.value.service } : {}
  )
}

# Ingress 규칙 중 cidr_blocks을 사용하는 규칙 생성
resource "aws_security_group_rule" "ingress_cidr" {
  for_each = {
    for sg_key, sg_rule in var.sg_rules :
    "${sg_key}_cidr" => sg_rule
    if sg_rule.type == "ingress" && length(try(lookup(sg_rule, "cidr_blocks", []), [])) > 0
  }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.sg[each.value.sg_name].id
  description       = each.value.description
  cidr_blocks       = try(each.value.cidr_blocks, [])
}

# Ingress 규칙 중 source_security_group_id를 사용하는 규칙 생성
resource "aws_security_group_rule" "ingress_sg" {
  for_each = {
    for sg_key, sg_rule in var.sg_rules :
    "${sg_key}_sg" => sg_rule
    if sg_rule.type == "ingress" && lookup(sg_rule, "source_sg_name", null) != null
  }

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.sg[each.value.sg_name].id
  description              = each.value.description
  source_security_group_id = aws_security_group.sg[each.value.source_sg_name].id
}

# Egress 규칙 생성
resource "aws_security_group_rule" "egress" {
  for_each = {
    for sg_key, sg_rule in var.sg_rules :
    sg_key => sg_rule
    if sg_rule.type == "egress"
  }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = try(each.value.cidr_blocks, [])
  security_group_id = aws_security_group.sg[each.value.sg_name].id
  description       = each.value.description
}
