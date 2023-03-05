provider "aws" {
  region = "ap-southeast-1"
  profile = "default"
}

resource "aws_vpc" "My_VPC" {
  cidr_block = var.cidr_block[0]

  tags = {
    Name = "My_VPC"
  }
}


# Create Subnet (Public)
resource "aws_subnet" "My_Subnet1" {
  vpc_id = aws_vpc.My_VPC.id
  cidr_block = var.cidr_block[1]

  tags = {
    Name = "My_Subnet1"
  }
}

# Create InternetGW (Public)
resource "aws_internet_gateway" "My_Gatew" {
  vpc_id = aws_vpc.My_VPC.id

  tags = {
    Name = "My_GateW"
  }
}


# Create SG Group 
resource "aws_security_group" "My_SG" {
  name = "My SG"
  description = "To allow inbound and outbound "
  vpc_id = aws_vpc.My_VPC.id

  dynamic ingress {
    iterator = port
    for_each = var.ports
    content {
      from_port = port.value
      to_port = port.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]


  }
  tags = {
    "Name" = "allow traffic"
  }
  
}

# Create route table and association

resource "aws_route_table" "My_RouteTable" {
    vpc_id = aws_vpc.My_VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.My_Gatew.id
    }
    tags = {
        Name = "My_RouteTable"
    }
}

resource "aws_route_table_association" "My_Asso" {
  subnet_id = aws_subnet.My_Subnet1.id
  route_table_id = aws_route_table.My_RouteTable.id

}


# Create an AWS EC2 Instance
# resource "aws_instance" "DemoResource"{
#     ami = var.ami
#     instance_type = var.instance_type
#     key_name = "demo1"
#     vpc_security_group_ids = [aws_security_group.My_SG.id]
#     subnet_id = aws_subnet.My_Subnet1.id
#     associate_public_ip_address = true

#     tags = {
#         Name = "Demo Instance"
#     }
# }

# Create an AWS EC2 Instance
resource "aws_instance" "AnsibleController"{
    ami = var.ami
    instance_type = var.instance_type
    key_name = "demo1"
    vpc_security_group_ids = [aws_security_group.My_SG.id]
    subnet_id = aws_subnet.My_Subnet1.id
    associate_public_ip_address = true
    user_data = file("InstallAnsibleCN.sh")

    tags = {
        Name = "AnsibleController"
    }
}

# Create an AnsibleNode1 to host Tomcat
resource "aws_instance" "AnsibleManagerNode1"{
    ami = var.ami
    instance_type = var.instance_type
    key_name = "demo1"
    vpc_security_group_ids = [aws_security_group.My_SG.id]
    subnet_id = aws_subnet.My_Subnet1.id
    associate_public_ip_address = true
    user_data = file("AnsibleManagedNode.sh")

    tags = {
        Name = "AnsibleMN-ApacheTomcat"
    }
}

# Create an AnsibleNode2 to host Docker
resource "aws_instance" "DockerHost"{
    ami = var.ami
    instance_type = var.instance_type
    key_name = "demo1"
    vpc_security_group_ids = [aws_security_group.My_SG.id]
    subnet_id = aws_subnet.My_Subnet1.id
    associate_public_ip_address = true
    user_data = file("Docker.sh")

    tags = {
        Name = "DockerHost"
    }
}

# Create an Nexus
resource "aws_instance" "Nexus"{
    ami = var.ami
    instance_type = var.instance_type_y2
    key_name = "demo1"
    vpc_security_group_ids = [aws_security_group.My_SG.id]
    subnet_id = aws_subnet.My_Subnet1.id
    associate_public_ip_address = true
    user_data = file("Docker.sh")

    tags = {
        Name = "Nexus Artifact"
    }
}


