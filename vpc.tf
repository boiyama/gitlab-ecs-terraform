# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.project}-vpc"
  }
}

data "aws_availability_zones" "available" {}

resource "null_resource" "az" {
  triggers {
    names = "${join(",", slice(data.aws_availability_zones.available.names, 0, 2))}"
  }
}

# Create subnets
resource "aws_subnet" "private" {
  count             = "${length(split(",", null_resource.az.triggers.names))}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + length(aws_subnet.public.*.id))}"
  availability_zone = "${element(split(",", null_resource.az.triggers.names), count.index)}"

  tags {
    Name = "${var.project}-subnet-private-${element(split(",", null_resource.az.triggers.names), count.index)}"
  }
}

resource "aws_subnet" "public" {
  count                   = "${length(split(",", null_resource.az.triggers.names))}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone       = "${element(split(",", null_resource.az.triggers.names), count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.project}-subnet-public-${element(split(",", null_resource.az.triggers.names), count.index)}"
  }
}

# Create gateways
resource "aws_nat_gateway" "main" {
  count         = "${length(aws_subnet.public.*.id)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags {
    Name = "${var.project}-ng-${element(aws_subnet.public.*.availability_zone, count.index)}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.project}-ig"
  }
}

# Create route tables
resource "aws_route_table" "private" {
  count  = "${length(aws_subnet.private.*.id)}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.project}-rt-private-${element(aws_subnet.private.*.availability_zone, count.index)}"
  }
}

resource "aws_route" "nat_gateway" {
  count                  = "${length(aws_route_table.private.*.id)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.main.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(aws_subnet.private.*.id)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.project}-rt-public"
  }
}

resource "aws_route" "internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(aws_subnet.public.*.id)}"
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}
