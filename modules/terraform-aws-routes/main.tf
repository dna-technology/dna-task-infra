resource "aws_route" "rt_from_source2destination" {
  count                  = var.route_table_ids_count
  route_table_id         = var.route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id     = var.tgw_id
}