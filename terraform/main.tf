provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
}


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all internal traffic and all TCP from outside"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ndb_mgmd" {
  ami                    = var.ami_id
  instance_type          = var.ndb_mgmd_instance_type
  subnet_id              = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.key_name

  tags = {
    Name = "ndb_mgmd"
  }
}

resource "aws_instance" "ndbmtd" {
  count                  = var.ndbmtd_count
  ami                    = var.ami_id
  instance_type          = var.ndbmtd_instance_type
  subnet_id              = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.key_name

  tags = {
    Name = "ndbmtd_${count.index + 1}"
  }
}

resource "aws_instance" "mysqld" {
  count                  = var.mysqld_count
  ami                    = var.ami_id
  instance_type          = var.mysqld_instance_type
  subnet_id              = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.key_name

  tags = {
    Name = "mysqld_${count.index + 1}"
  }
}

resource "aws_instance" "rdrs" {
  count                  = var.rdrs_count
  ami                    = var.ami_id
  instance_type          = var.rdrs_instance_type
  subnet_id              = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.key_name

  tags = {
    Name = "rdrs_${count.index + 1}"
  }
}

resource "aws_instance" "benchmark" {
  count                  = var.benchmark_count
  ami                    = var.ami_id
  instance_type          = var.benchmark_instance_type
  subnet_id              = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.key_name

  tags = {
    Name = "benchmark_${count.index + 1}"
  }
}

locals {
  rdrs_private_ips = [for instance in aws_instance.rdrs : instance.private_ip]
}

resource "aws_lb" "rdrs_alb" {
  name               = "rdrs-lbs"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_all.id]
  subnets            = [aws_subnet.main.id, aws_subnet.subnet_b.id]
}

resource "aws_lb_target_group" "rdrs_tg" {
  name        = "rdrs-targets"
  port        = 5406
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "rdrs_tg_attachments" {
  for_each = { for idx, inst in aws_instance.rdrs : idx => inst }
  target_group_arn  = aws_lb_target_group.rdrs_tg.arn
  target_id        = each.value.private_ip
  port              = 5406
}

resource "aws_lb_listener" "rdrs_listener" {
  load_balancer_arn = aws_lb.rdrs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rdrs_tg.arn
  }
}

resource "aws_lb" "rondis_nlb" {
  name               = "rondis-lbs"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.main.id, aws_subnet.subnet_b.id]
}

resource "aws_lb_target_group" "rondis_tg" {
  name        = "rondis-targets"
  port        = 6379
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "rondis_tg_attachments" {
  for_each = { for idx, inst in aws_instance.rdrs : idx => inst }
  target_group_arn  = aws_lb_target_group.rondis_tg.arn
  target_id        = each.value.private_ip
  port              = 6379
}

resource "aws_lb_listener" "rondis_listener" {
  load_balancer_arn = aws_lb.rondis_nlb.arn
  port              = 6379
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rondis_tg.arn
  }
}
