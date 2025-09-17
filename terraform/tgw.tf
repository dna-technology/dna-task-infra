locals {
  aws_private_asn         = 64532
  restore-aws_private_asn = 64533
}

module "tgw" {
  count = lookup(var.create_tgw, var.environment) ? 1 : 0

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-transit-gateway?ref=v2.12.2"

  name            = "${var.namespace}-${var.environment}-tgw"
  amazon_side_asn = local.aws_private_asn

  enable_auto_accept_shared_attachments = true

  vpc_attachments = {
    vpc = {
      vpc_id                                          = module.vpc.vpc_id
      subnet_ids                                      = module.vpc.intra_subnets
      dns_support                                     = true
      ipv6_support                                    = false
      transit_gateway_default_route_table_association = true
      transit_gateway_default_route_table_propagation = true

      tgw_routes = [
        {
          blackhole              = true
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    }
  }

  ram_allow_external_principals = true
  ram_principals                = lookup(var.transit_gw_account_map, var.environment)

  tags = {
    Namespace   = var.namespace
    Environment = var.environment
  }
}

locals {
  external_private_routes = lookup(var.create_tgw, var.environment) ? setproduct(module.vpc.private_route_table_ids, lookup(var.routing_cidr_map, var.environment)) : []
}

resource "aws_route" "tgw_private_route" {
  count = lookup(var.create_tgw, var.environment) ? length(local.external_private_routes) : 0

  route_table_id         = local.external_private_routes[count.index][0]
  destination_cidr_block = local.external_private_routes[count.index][1]
  transit_gateway_id     = module.tgw[0].ec2_transit_gateway_id
}
