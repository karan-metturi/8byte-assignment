resource "aws_vpc" "karan_vpc" {
  cidr_block = "10.20.0.0/16"

  tags = {
    Name = "karan-vpc"
  }
}

resource "aws_subnet" "karan_public_1" {
  vpc_id                  = aws_vpc.karan_vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "karan-public-1"
  }
}

resource "aws_subnet" "karan_public_2" {
  vpc_id                  = aws_vpc.karan_vpc.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "karan-public-2"
  }
}

resource "aws_internet_gateway" "karan_igw" {
  vpc_id = aws_vpc.karan_vpc.id

  tags = {
    Name = "karan-igw"
  }
}

resource "aws_route_table" "karan_public_rt" {
  vpc_id = aws_vpc.karan_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.karan_igw.id
  }

  tags = {
    Name = "karan-public-rt"
  }
}

resource "aws_route_table_association" "karan_public_assoc_1" {
  subnet_id      = aws_subnet.karan_public_1.id
  route_table_id = aws_route_table.karan_public_rt.id
}

resource "aws_route_table_association" "karan_public_assoc_2" {
  subnet_id      = aws_subnet.karan_public_2.id
  route_table_id = aws_route_table.karan_public_rt.id
}

resource "aws_subnet" "karan_private_1" {
  vpc_id                  = aws_vpc.karan_vpc.id
  cidr_block              = "10.20.3.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "karan-private-1"
  }
}

resource "aws_subnet" "karan_private_2" {
  vpc_id                  = aws_vpc.karan_vpc.id
  cidr_block              = "10.20.4.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "karan-private-2"
  }
}

resource "aws_security_group" "karan_alb_sg" {
  name        = "karan-alb-sg"
  description = "Allow inibound HTTP traffic"
  vpc_id      = aws_vpc.karan_vpc.id

  ingress {
    description = "HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "karan-alb-sg"
  }
}

resource "aws_security_group" "karan_ecs_sg" {
  name        = "karan-ecs-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.karan_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.karan_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "karan-ecs-sg"
  }
}

resource "aws_security_group" "karan_db_sg" {
  name        = "karan-db-sg"
  description = "Allow postgres traffic from ECS"
  vpc_id      = aws_vpc.karan_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.karan_ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "karan-db-sg"
  }
}
