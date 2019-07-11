# Terraform AWS NAT module
=========================

> Create a AWS NAT Gateway Resource

## Create a NAT Gateway and minimum related resources
- Route Table
- Elastic IP
- Public Subnet
- Nat Gateway
- Route Table Association: Associate with NAT Public Subnet
- Network ACL: Associate with NAT Public Subnet

``` yaml
module "nat" {
  source = "Aplyca/nat/aws"
  name   = "NAT MyProject"
  env   = "MyProject Cluster"
  vpc_cidr  = "172.0.0.0/16"
  vpc_id = "vpc-12345abcd"
  vpc_ig = "igw-12345abcd"
  ssh_open = ["<myip>/32"]
  http_open = ["0.0.0.0/0"]
  https_open = ["0.0.0.0/0"]
  ephemeral_open = ["0.0.0.0/0"]
  azs    = "[us-east-1a,us-east-1b,us-east-1c]"
  newbits  = 10
  netnum  = 16
  tags {
    App = "${local.name}"
    Environment = "${local.env} NAT"
  }
}
```

## Use The NAT Gateway
``` yaml
module "vpc" {
  source = "Aplyca/vpc/aws"
  name   = "VPC MyProject"
  env   = "MyProject Cluster"
  # CIDR for the VPC
  cidr   = "172.0.0.0/16"
  # Subnet CIDR configuration
  newbits  = 8
  netnum  = 0
  ssh_open = ["<myip>/32"]
  http_open = ["0.0.0.0/0"]
  https_open = ["0.0.0.0/0"]
  ephemeral_open = ["0.0.0.0/0"]
  nat_gw_id = "${module.nat.nat_gw_id}"
  nat_subnet = "${module.nat.subnet_id}"
  nat_traffic_routes = ["destinyIP0","destinyIP1","destinyIP2"]
  azs     = "[us-east-1a,us-east-1b,us-east-1c]"
  tags {
    App = "${local.name}"
    Environment = "${local.env}"
  }
}
```

