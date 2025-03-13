resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.project}-vpc"
    terraform = "true"
    purpose   = "EKS"
  }
}

# SUBNETS
resource "aws_subnet" "public_subnet" {
  count                   = length(var.AZs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = element(var.AZs, count.index)
  map_public_ip_on_launch = true


  tags = {
    Name                                   = "${var.project}-public-${count.index + 1}"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/${var.project}" = "owned"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.AZs)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone = element(var.AZs, count.index)

  tags = {
    Name                                   = "${var.project}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/${var.project}" = "owned"
  }
}

# create NAT gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-nat-eip"
  }

}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet[*].id, 0)

  tags = {
    Name = "${var.project}-nat"
  }

  depends_on = [aws_internet_gateway.eks_igw]
}


# create internet gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# create route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
  tags = {
    Name = "${var.project}-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.project}-private"
  }
}

# associate route table with subnets
resource "aws_route_table_association" "public" {
  count          = length(var.AZs)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.AZs)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private.id
}