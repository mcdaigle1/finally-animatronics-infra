# ----------------------------
# Create VPC and Subnets
# ----------------------------
resource "aws_vpc" "finally_animatronics_vpc" {
  cidr_block = "10.4.0.0/16"
  
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "finally_animatronics_vpc"
  }
}

variable "azs" {
  default = ["us-west-1a", "us-west-1c"]
}

resource "aws_subnet" "finally_animatronics_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.finally_animatronics_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.finally_animatronics_vpc.cidr_block, 8, count.index + 100)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "finally-animatronics-public-subnet-${var.azs[count.index]}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/finally-anim-eks" = "owned"
 }
}

resource "aws_subnet" "finally_animatronics_private_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.finally_animatronics_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.finally_animatronics_vpc.cidr_block, 8, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false
  
  tags = {
    Name = "finally-animatronics-private-subnet-${var.azs[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/finally-anim-eks" = "owned"
 }
}

resource "aws_internet_gateway" "finally_animatronics_igw" {
 vpc_id = aws_vpc.finally_animatronics_vpc.id

 tags = {
   Name = "finally-animatronics-igw"
 }
}

resource "aws_eip" "finally_animatronics_nat_eip" {
  domain  = "vpc"
}

resource "aws_nat_gateway" "finally_animatronics_nat" {
  allocation_id = aws_eip.finally_animatronics_nat_eip.id
  subnet_id     = aws_subnet.finally_animatronics_public_subnet[0].id
  depends_on    = [aws_internet_gateway.finally_animatronics_igw]
}

resource "aws_route_table" "finally_animatronics_public_rt" {
  vpc_id = aws_vpc.finally_animatronics_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.finally_animatronics_igw.id
  }
}

resource "aws_route_table_association" "finally_animatronics_public_rta" {
  count          = 2

  subnet_id      = aws_subnet.finally_animatronics_public_subnet[count.index].id
  route_table_id = aws_route_table.finally_animatronics_public_rt.id
}

resource "aws_route_table" "finally_animatronics_private_rt" {
 vpc_id = aws_vpc.finally_animatronics_vpc.id

 route {
   cidr_block = "0.0.0.0/0"
   nat_gateway_id = aws_nat_gateway.finally_animatronics_nat.id
 }

 tags = {
   Name = "finally-animatronics-private-rt"
 }
}

resource "aws_route_table_association" "finally_animatronics_private_rta" {
 count          = 2
 subnet_id      = aws_subnet.finally_animatronics_private_subnet.*.id[count.index]
 route_table_id = aws_route_table.finally_animatronics_private_rt.id
}