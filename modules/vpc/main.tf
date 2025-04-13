locals {
  subnet_groups = {
    for idx, az in var.availability_zones :
    idx + 1 => az
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.environment}-VPC"
  }
}

# resource "aws_subnet" "subnets" {
#   for_each = var.subnets
#
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = each.value.cidr_block
#   map_public_ip_on_launch = each.value.map_public_ip_on_launch
#   availability_zone       = each.value.availability_zone
#
#   tags = {
#     Name = "${var.environment}-${each.value.subnet_id}-Sub-${each.value.subnet_number}${each.value.az_id}"
#   }
# }

resource "aws_subnet" "public_subnets" {
  for_each = local.subnet_groups

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets_cidr[each.key - 1]
  map_public_ip_on_launch = true
  availability_zone       = each.value

  tags = {
    Name = "${var.environment}-Pub-Sub-${(each.key <= 2 ? 1 : 2)}${substr(each.value, length(each.value) - 1, 1)}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = local.subnet_groups

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_cidr[each.key - 1]
  availability_zone = each.value

  tags = {
    Name = "${var.environment}-Pri-Sub-${(each.key <= 2 ? 1 : 2)}${substr(each.value, length(each.value) - 1, 1)}"
  }
}

resource "aws_subnet" "mgmt_subnets" {
  for_each = local.subnet_groups

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = try(var.mgmt_subnets_cidr[each.key - 1], null)
  availability_zone = each.value

  tags = {
    Name = "${var.environment}-MGMT-Sub-${(each.key <= 2 ? 1 : 2)}${substr(each.value, length(each.value) - 1, 1)}"
  }
}

resource "aws_subnet" "db_subnets" {
  for_each = local.subnet_groups

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.db_subnets_cidr[each.key - 1]
  availability_zone = each.value

  tags = {
    Name = "${var.environment}-DB-Sub-${(each.key <= 2 ? 1 : 2)}${substr(each.value, length(each.value) - 1, 1)}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-Pub-RT"
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name = "${var.environment}-NAT-EIP"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[keys(aws_subnet.public_subnets)[0]].id

  tags = {
    Name = "${var.environment}-NAT"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "${var.environment}-Pri-RT"
  }
}

resource "aws_route_table" "db_rt" {
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "${var.environment}-DB-RT"
  }
}

resource "aws_route_table" "mgmt_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "${var.environment}-MGMT-RT"
  }
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "mgmt_assoc" {
  for_each = aws_subnet.mgmt_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.mgmt_rt.id
}

resource "aws_route_table_association" "db_assoc" {
  for_each = aws_subnet.db_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.db_rt.id
}


# resource "aws_vpn_gateway" "ratel_vgw" {
#   vpc_id = aws_vpc.dev_vpc.id

#   tags = {
#     Name = var.vpn_gateway_tag_name
#   }
# }

# resource "aws_customer_gateway" "ratel_cgw" {
#   bgp_asn    = var.bgp_asn
#   ip_address = var.customer_gateway_ip
#   type       = "ipsec.1"

#   tags = {
#     Name = var.customer_gateway_tag_name
#   }
# }

# resource "aws_vpn_connection" "ratel_s2s_vpn" {
#   customer_gateway_id = aws_customer_gateway.ratel_cgw.id
#   vpn_gateway_id      = aws_vpn_gateway.ratel_vgw.id
#   type                = "ipsec.1"

#   tunnel1_preshared_key = var.tunnel1_preshared_key
#   tunnel1_inside_cidr   = var.tunnel1_inside_cidr

#   tunnel2_preshared_key = var.tunnel2_preshared_key
#   tunnel2_inside_cidr   = var.tunnel2_inside_cidr

#   static_routes_only = true

#   tags = {
#     Name = var.vpn_connection_tag_name
#   }
# }

# resource "aws_route" "route_table_association_vpn_ratel" {
#   route_table_id         = aws_route_table.route_table_private.id
#   destination_cidr_block = var.vpn_ratel_destination_cidr
#   gateway_id             = aws_vpn_connection.ratel_s2s_vpn.id
# }
