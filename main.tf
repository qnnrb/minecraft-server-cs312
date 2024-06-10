terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }
  }
  //required_version = "~> 1.8.4"
} 

/*provider "aws" {
  profile = "default"
  region  = "us-west-2"
}*/

variable "availability_zones" {
    default = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]
    type = list
}

variable "subnet_cidr" {
    default = ["172.31.16.0/20", "172.31.32.0/20", "172.31.0.0/20", "172.31.48.0/20"]
    type = list
}

resource "aws_vpc" "terraform_minecraft_vpc" {
    cidr_block = "172.31.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
    count = "${length(var.subnet_cidr)}"
    vpc_id = aws_vpc.terraform_minecraft_vpc.id
    cidr_block = "${var.subnet_cidr[count.index]}"
    availability_zone = "${var.availability_zones[count.index]}"
}

resource "aws_internet_gateway" "minecraft_ig" {
    vpc_id = aws_vpc.terraform_minecraft_vpc.id
}

resource "aws_route_table" "minecraft_rt" {
    vpc_id = aws_vpc.terraform_minecraft_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.minecraft_ig.id
    }
}

resource "aws_route_table_association" "minecraft_rta" {
    count = "${length(var.subnet_cidr)}"

    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id = aws_route_table.minecraft_rt.id
}

resource "aws_security_group" "minecraft" {
  name = "course_project_2_sg"
  vpc_id = aws_vpc.terraform_minecraft_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 25565
    to_port     = 25565
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
    Name = "Minecraft"
  }
} 

resource "tls_private_key" "pk" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}

resource "aws_instance" "minecraft" {
  ami                         = "ami-05a6dba9ac2da60cb"
  instance_type               = "t4g.small"
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public[3].id
  key_name                    = aws_key_pair.kp.key_name

  provisioner "file" {
    source = "script.sh"
    destination = "/home/ec2-user/script.sh"

    connection {
    host = self.public_ip
    //agent = true
    type = "ssh"
    user = "ec2-user"
    private_key = tls_private_key.pk.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = ["sudo chmod +x /home/ec2-user/script.sh", "sudo cd /home/ec2-user","sudo ./script.sh"]

    connection {
    host = self.public_ip
    //agent = true
    type = "ssh"
    user = "ec2-user"
    private_key = tls_private_key.pk.private_key_pem
    }
  }

  tags = {
    Name = "Minecraft"
  }
} 

output "instance_ip_addr" {
  value = aws_instance.minecraft.public_ip
}

output "publis_dns" {
  value = aws_instance.minecraft.public_dns
}