

resource "aws_iam_role_policy_attachment" "full_access" {
  role       = aws_iam_role.emr_serverless_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3TablesFullAccess"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-s3tables-app"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_vpc_endpoint" "s3tables_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.region}.s3tables"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_subnet.id
  ]

  security_group_ids = [
    aws_security_group.private_sg.id
  ]

}

resource "aws_vpc_endpoint" "cloudwatch_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_subnet.id
  ]

  security_group_ids = [
    aws_security_group.private_sg.id
  ]

}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "s3_route_endpoint" {
  route_table_id  = aws_vpc.vpc.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}

resource "aws_security_group" "private_sg" {
  name_prefix = "vpc-endpoint-sg"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "private-sg"
  }
}
