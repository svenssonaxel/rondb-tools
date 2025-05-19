provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

data "aws_availability_zones" "available" {}

# Subnets
resource "aws_subnet" "subnet" {
  count             = var.use_multiple_azs ? 3 : 1
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "vm-subnet-${count.index}"
  }
}

# Get the list of subnet IDs
locals {
  selected_subnets = aws_subnet.subnet[*].id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate each subnet with the public route table
resource "aws_route_table_association" "rt" {
  count          = length(local.selected_subnets)
  subnet_id      = local.selected_subnets[count.index]
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
  subnet_id              = aws_subnet.subnet_a.id
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
  subnet_id              = local.selected_subnets[count.index % length(local.selected_subnets)]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = var.ndbmtd_disk_size
    volume_type = "gp3"
  }

  tags = {
    Name = "ndbmtd_${count.index + 1}"
  }
}

resource "aws_instance" "mysqld" {
  count                  = var.mysqld_count
  ami                    = var.ami_id
  instance_type          = var.mysqld_instance_type
  subnet_id              = local.selected_subnets[count.index % length(local.selected_subnets)]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = var.mysqld_disk_size
    volume_type = "gp3"
  }

  tags = {
    Name = "mysqld_${count.index + 1}"
  }
}

resource "aws_instance" "rdrs" {
  count                  = var.rdrs_count
  ami                    = var.ami_id
  instance_type          = var.rdrs_instance_type
  subnet_id              = local.selected_subnets[count.index % length(local.selected_subnets)]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = var.rdrs_disk_size
    volume_type = "gp3"
  }

  tags = {
    Name = "rdrs_${count.index + 1}"
  }
}

resource "aws_instance" "benchmark" {
  count                  = var.benchmark_count
  ami                    = var.ami_id
  instance_type          = var.benchmark_instance_type
  subnet_id              = local.selected_subnets[count.index % length(local.selected_subnets)]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = var.benchmark_disk_size
    volume_type = "gp3"
  }

  tags = {
    Name = "benchmark_${count.index + 1}"
  }
}

locals {
  rdrs_private_ips = [for instance in aws_instance.rdrs : instance.private_ip]
}

resource "aws_lb" "rdrs_nlb" {
  name               = "rdrs-lbs"
  internal           = true
  load_balancer_type = "network"
  subnets            = local.selected_subnets
}

resource "aws_lb_target_group" "rdrs_tg" {
  name        = "rdrs-targets"
  port        = 4406
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "rdrs_tg_attachments" {
  count             = var.rdrs_count
  target_group_arn  = aws_lb_target_group.rdrs_tg.arn
  target_id         = aws_instance.rdrs[count.index].id
  port              = 4406
}

resource "aws_lb_listener" "rdrs_listener" {
  load_balancer_arn = aws_lb.rdrs_nlb.arn
  port              = 4406
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rdrs_tg.arn
  }
}

resource "aws_lb" "rondis_nlb" {
  name               = "rondis-lbs"
  internal           = true
  load_balancer_type = "network"
  subnets            = local.selected_subnets
}

resource "aws_lb_target_group" "rondis_tg" {
  name        = "rondis-targets"
  port        = 6379
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "rondis_tg_attachments" {
  count             = var.rdrs_count
  target_group_arn  = aws_lb_target_group.rondis_tg.arn
  target_id         = aws_instance.rdrs[count.index].id
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
