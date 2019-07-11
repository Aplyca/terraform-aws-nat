output "rt_nat_id" {
  value = "${aws_route_table.this.id}"
}

output "subnets_cidr" {
  value = "${aws_subnet.this.*.cidr_block}"
}

output "subnet_id" {
  value = "${aws_subnet.this.id}"
}

output "nat_gw_id" {
  value = "${aws_nat_gateway.this.id}"
}
