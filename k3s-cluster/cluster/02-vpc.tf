# Define our VPC
resource "aws_vpc" "k3s-vpc" {
  cidr_block           = var.k3s-vpc-cidr
  enable_dns_hostnames = true

  tags = {
    Name = "k3s-vpc"
  }
}

#Define public subnets
resource "aws_subnet" "k3s-public-subnet-01" {
  vpc_id            = aws_vpc.k3s-vpc.id
  cidr_block        = var.k3s-public-subnet-cidr-01
  availability_zone = "us-east-1a"

  tags = {
    Name = "k3s-pub-sub-01"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/linnworks-k3s-cluster" = "shared"
  }
}

resource "aws_subnet" "k3s-public-subnet-02" {
  vpc_id            = aws_vpc.k3s-vpc.id
  cidr_block        = var.k3s-public-subnet-cidr-02
  availability_zone = "us-east-1b"

  tags = {
    Name = "k3s-pub-sub-02"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/linnworks-k3s-cluster" = "shared"
  }
}

resource "aws_subnet" "k3s-public-subnet-03" {
  vpc_id            = aws_vpc.k3s-vpc.id
  cidr_block        = var.k3s-public-subnet-cidr-03
  availability_zone = "us-east-1c"

  tags = {
    Name = "k3s-pub-sub-03"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/linnworks-k3s-cluster" = "shared"
  }
}

#Define private subnets
resource "aws_subnet" "k3s-private-subnet-01" {
  vpc_id            = aws_vpc.k3s-vpc.id
  cidr_block        = var.k3s-private-subnet-cidr-01
  availability_zone = "us-east-1a"

  tags = {
    Name = "k3s-prv-sub-01"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/linnworks-k3s-cluster" = "shared"
  }
}

resource "aws_subnet" "k3s-private-subnet-02" {
  vpc_id            = aws_vpc.k3s-vpc.id
  cidr_block        = var.k3s-private-subnet-cidr-02
  availability_zone = "us-east-1b"

  tags = {
    Name = "k3s-prv-sub-02"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/linnworks-k3s-cluster" = "shared"
  }
}

resource "aws_subnet" "k3s-private-subnet-03" {
  vpc_id            = aws_vpc.k3s-vpc.id
  cidr_block        = var.k3s-private-subnet-cidr-03
  availability_zone = "us-east-1c"

  tags = {
    Name = "k3s-prv-sub-03"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/linnworks-k3s-cluster" = "shared"
  }
}


# Define internet gateway
resource "aws_internet_gateway" "k3s-igw" {
  vpc_id = aws_vpc.k3s-vpc.id

  tags = {
    Name = "k3s-igw"
  }
}

#Define nat gateway
resource "aws_eip" "k3s-nat-gw-eip" {
  vpc                       = true
  tags = {
    Name = "k3s-nat-gw-eip"
  }
}

resource "aws_nat_gateway" "k3s-nat-gw" {
  allocation_id = "${aws_eip.k3s-nat-gw-eip.id}"
  subnet_id     = aws_subnet.k3s-public-subnet-01.id
  tags = {
    Name = "k3s-nat-gw"
  }

  depends_on = [aws_internet_gateway.k3s-igw, aws_eip.k3s-nat-gw-eip]
}

#Define the public route table
resource "aws_route_table" "k3s-pub-rtb" {
  vpc_id = aws_vpc.k3s-vpc.id

  tags = {
    Name = "k3s-pub-rtb"
  }
}

#Define the private route table
resource "aws_route_table" "k3s-prv-rtb" {
  vpc_id = aws_vpc.k3s-vpc.id
  tags = {
    Name = "k3s-prv-rtb"
  }
}

# Assign the public subnets to public route table
resource "aws_route_table_association" "k3s-pub-rtb-assoc-01" {
  subnet_id      = aws_subnet.k3s-public-subnet-01.id
  route_table_id = aws_route_table.k3s-pub-rtb.id
}

resource "aws_route_table_association" "k3s-pub-rtb-assoc-02" {
  subnet_id      = aws_subnet.k3s-public-subnet-02.id
  route_table_id = aws_route_table.k3s-pub-rtb.id
}

resource "aws_route_table_association" "k3s-pub-rtb-assoc-03" {
  subnet_id      = aws_subnet.k3s-public-subnet-03.id
  route_table_id = aws_route_table.k3s-pub-rtb.id
}

# Assign the private subnets to private route table
resource "aws_route_table_association" "k3s-prv-rtb-assoc-01" {
  subnet_id      = aws_subnet.k3s-private-subnet-01.id
  route_table_id = aws_route_table.k3s-prv-rtb.id
}

resource "aws_route_table_association" "k3s-prv-rtb-assoc-02" {
  subnet_id      = aws_subnet.k3s-private-subnet-02.id
  route_table_id = aws_route_table.k3s-prv-rtb.id
}

resource "aws_route_table_association" "k3s-prv-rtb-assoc-03" {
  subnet_id      = aws_subnet.k3s-private-subnet-03.id
  route_table_id = aws_route_table.k3s-prv-rtb.id
}

#Route to internet gateway from public route table
resource "aws_route" "k3s-igw-route" {
  route_table_id            = aws_route_table.k3s-pub-rtb.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.k3s-igw.id
  depends_on                = [aws_route_table.k3s-pub-rtb, aws_internet_gateway.k3s-igw]
}

resource "aws_route" "k3s-nat-gw-route" {
  route_table_id            = aws_route_table.k3s-prv-rtb.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.k3s-nat-gw.id
  depends_on                = [aws_route_table.k3s-prv-rtb, aws_nat_gateway.k3s-nat-gw]
}