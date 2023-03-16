resource "aws_vpc" "burning-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.company}-${var.env}-vpc"
  }
}

resource "aws_subnet" "pub_sub" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.burning-vpc.id
  cidr_block              = var.public_subnets[count.index].cidr
  availability_zone       = var.public_subnets[count.index].zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.company}-${var.public_subnets[count.index].name}"
  }
}

resource "aws_subnet" "pri_sub" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.burning-vpc.id
  cidr_block              = var.private_subnets[count.index].cidr
  availability_zone       = var.private_subnets[count.index].zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.company}-${var.private_subnets[count.index].name}"
  }
}

resource "aws_subnet" "db_sub" {
  count                   = length(var.db_subnets)
  vpc_id                  = aws_vpc.burning-vpc.id
  cidr_block              = var.db_subnets[count.index].cidr
  availability_zone       = var.db_subnets[count.index].zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.company}-${var.db_subnets[count.index].name}"
  }
}
# igw 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.burning-vpc.id

  tags = {
    Name = "${var.company}-igw-${var.env}-vpc-apne2"
  }
}
# public routing table 생성
resource "aws_route_table" "rt_pub" {
  vpc_id = aws_vpc.burning-vpc.id

  tags = {
    Name = "${var.company}-rt-${var.env}-apne2"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}
# 퍼블릭 라우팅 테이블과 igw 연결
resource "aws_route" "name" {
  route_table_id         = aws_route_table.rt_pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  depends_on = [
    aws_route_table.rt_pub,
    aws_internet_gateway.igw
  ]
}

# public routing table에 public subnet들 연결
resource "aws_route_table_association" "rta_pub" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.pub_sub[count.index].id
  route_table_id = aws_route_table.rt_pub.id
}

resource "aws_eip" "nat_ip" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_nat_gateway" "nat_web_pri" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.pub_sub[0].id

  tags = {
    Name = "${var.company}-ntgw-${var.env}-pub-apne2a"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}
# web private routing table
resource "aws_route_table" "rt_web_pri" {
  vpc_id = aws_vpc.burning-vpc.id

  tags = {
    Name = "${var.company}-rt-${var.env}-web-apne2"
  }
}
# 프라이빗 웹 라우팅 테이블과 nat 연결
resource "aws_route" "pri_web_rt_nat" {
  route_table_id         = aws_route_table.rt_web_pri.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_web_pri.id

  depends_on = [
    aws_nat_gateway.nat_web_pri,
    aws_route_table.rt_web_pri
  ]
}

resource "aws_route_table_association" "rta_web_pri" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.pri_sub[count.index].id
  route_table_id = aws_route_table.rt_web_pri.id
}
# DB private routing table
resource "aws_route_table" "rt_db_pri" {
  vpc_id = aws_vpc.burning-vpc.id

  tags = {
    Name = "${var.company}-rt-${var.env}-db-apne2"
  }
}

resource "aws_route_table_association" "rta_db_pri" {
  count          = length(var.db_subnets)
  subnet_id      = aws_subnet.db_sub[count.index].id
  route_table_id = aws_route_table.rt_db_pri.id
}