# Fetch available AZs dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

# 1. The VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.project_name}-vpc" }
}

# 2. The 6 Subnets
resource "aws_subnet" "web_public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1) # e.g., 10.0.1.0/24
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project_name}-web-public-a" }
}

resource "aws_subnet" "web_public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2) # e.g., 10.0.2.0/24
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project_name}-web-public-b" }
}

resource "aws_subnet" "app_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 3) # e.g., 10.0.3.0/24
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = { Name = "${var.project_name}-app-private-a" }
}

resource "aws_subnet" "app_private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 4)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags              = { Name = "${var.project_name}-app-private-b" }
}

resource "aws_subnet" "db_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 5)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = { Name = "${var.project_name}-db-private-a" }
}

resource "aws_subnet" "db_private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 6)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags              = { Name = "${var.project_name}-db-private-b" }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

# 4. NAT Gateway (For App Tier outbound internet)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = { Name = "${var.project_name}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.web_public_a.id # NAT must live in a public subnet
  tags          = { Name = "${var.project_name}-nat" }
  depends_on    = [aws_internet_gateway.igw]
}

# 5. Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${var.project_name}-private-rt" }
}

# 6. Route Table Associations
resource "aws_route_table_association" "pub_a" {
  subnet_id      = aws_subnet.web_public_a.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "pub_b" {
  subnet_id      = aws_subnet.web_public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "priv_app_a" {
  subnet_id      = aws_subnet.app_private_a.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "priv_app_b" {
  subnet_id      = aws_subnet.app_private_b.id
  route_table_id = aws_route_table.private_rt.id
}

