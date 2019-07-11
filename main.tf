locals {
  id = "${replace(var.name, " ", "-")}"
}

# -----------------------------------------------
# Create Public Routing
# -----------------------------------------------
resource "aws_route_table" "this" {
  vpc_id = "${var.vpc_id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${var.vpc_ig}"
  }

  tags = "${merge(var.tags, map("Name", "${var.name}"))}"
}

# -----------------------------------------------
# NAT EIP
# -----------------------------------------------
resource "aws_eip" "this" {
  vpc = true
  tags = "${merge(var.tags, map("Name", "${var.name}"))}"
  lifecycle {
    prevent_destroy = true
  }
}

# -----------------------------------------------
# Create NAT subnet
# -----------------------------------------------
resource "aws_subnet" "this" {
  count = "1"
  vpc_id = "${var.vpc_id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, var.newbits, var.netnum + count.index)}"
	availability_zone = "${element(var.azs, count.index)}"
	map_public_ip_on_launch = true
  tags = "${merge(var.tags, map("Name", "${var.name} ${var.env} ${count.index}"))}"
}

# ---------------------------------------------
# NAT
# ---------------------------------------------
resource "aws_nat_gateway" "this" {
  allocation_id = "${aws_eip.this.id}"
  subnet_id     = "${aws_subnet.this.id}"

  tags = {
    Name = "NAT GEB"
  }
}

# ---------------------------------------------
# Associate 
# ---------------------------------------------
resource "aws_route_table_association" "this" {
  subnet_id         = "${aws_subnet.this.id}"
  route_table_id = "${aws_route_table.this.id}"
}


# Network ACL Web Access
resource "aws_network_acl" "this" {
    vpc_id = "${var.vpc_id}"
    subnet_ids = ["${aws_subnet.this.id}"]
    tags = "${merge(var.tags, map("Name", "${var.name} ${var.env} ACL"),map("Description", "Use a Custom ACL to avoid adding the NAT Subnet to the Default ACL."))}"
}

resource "aws_network_acl_rule" "egress" {
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number = 100
  egress      = true
  protocol    = -1
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = -1
  to_port     = -1
}

resource "aws_network_acl_rule" "ingress_ephemeral" {
  count       = "${length(var.ephemeral_open)}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number = "${100 + count.index}"
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "${element(var.ephemeral_open, count.index)}"
  from_port   = 1024
  to_port     = 65535
}

resource "aws_network_acl_rule" "ingress_ssh" {
  count       = "${length(var.ssh_open)}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number = "${200 + count.index}"
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "${element(var.ssh_open, count.index)}"
  from_port   = 22
  to_port     = 22
}

resource "aws_network_acl_rule" "ingress_http" {
  count       = "${length(var.http_open)}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number = "${300 + count.index}"
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "${element(var.http_open, count.index)}"
  from_port   = 80
  to_port     = 80
}

resource "aws_network_acl_rule" "ingress_https" {
  count       = "${length(var.https_open)}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number = "${400 + count.index}"
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "${element(var.https_open, count.index)}"
  from_port   = 443
  to_port     = 443
}