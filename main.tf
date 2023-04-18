resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true ## allow instances create on this subnet have public ip 
  availability_zone       = "ap-southeast-1a"

  tags = {
    "Name" = "dev-public"
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "dev_igw"
  }

}

resource "aws_route_table" "dev_public" {
  vpc_id = aws_vpc.main.id

}

resource "aws_route" "name" {
  route_table_id         = aws_route_table.dev_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

resource "aws_route_table_association" "dev_public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.dev_public.id
}

resource "aws_security_group" "dev_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_key_pair" "dev" {
#   key_name = "dev"
#   public_key = file("~/.ssh/id_rsa.pub")
# }

resource "aws_instance" "dev" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.server_ami.id
  # key_name = aws_key_pair.dev.key_name
  key_name               = "son-test"
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    "Name" = "dev-instance"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/id_rsa"
    })
    # command = "echo first"
    # interpreter = ["bash", "-c"]
  }
}