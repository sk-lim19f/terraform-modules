variable "vpc_cidr" {
  type = string
}

# variable "subnets" {
#   type = map(object({
#     cidr_block              = string
#     map_public_ip_on_launch = bool
#     availability_zone       = string
#
#     subnet_id     = string
#     subnet_number = number
#     az_id         = string
#   }))
# }

variable "public_subnets_cidr" {
  type = list(string)
}

variable "private_subnets_cidr" {
  type = list(string)
}

variable "db_subnets_cidr" {
  type = list(string)
}

variable "mgmt_subnets_cidr" {
  type = list(string)
}

variable "availability_zones" {
  type = map(string)
}

variable "environment" {
  type = string
}

# variable "vpn_gateway_tag_name" {
#   type        = string
# }

# variable "customer_gateway_tag_name" {
#   type        = string
# }

# variable "bgp_asn" {
#   type        = number
# }

# variable "customer_gateway_ip" {
#   type        = string
# }

# variable "tunnel1_preshared_key" {
#   type        = string
# }

# variable "tunnel1_inside_cidr" {
#   type        = string
# }

# variable "tunnel2_preshared_key" {
#   type        = string
# }

# variable "tunnel2_inside_cidr" {
#   type        = string
# }

# variable "vpn_connection_tag_name" {
#   type        = string
# }

# variable "vpn_ratel_destination_cidr" {
#   type        = string
# }
