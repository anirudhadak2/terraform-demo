### VPC Creation 
resource  "aws_vpc"  "network1" {
          instance_tenancy = "default"
          cidr_block = "100.100.0.0/16"
          tags = {
                 Name = "DevelopmentNetwork"
           }
  }



### Internet Gateway
resource "aws_internet_gateway" "mygetway" {
   vpc_id = aws_vpc.network1.id

    tags = {
      Name = "Network1_Int_gateway"
  }
 }



###  Subnet on one AZ
resource "aws_subnet"  "network1_sub1" {
  vpc_id = aws_vpc.network1.id
  cidr_block = "100.100.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "Network1_Subnet1"
   }
  }

### Route Table
 resource "aws_route_table" "myroute1" { 
  vpc_id = aws_vpc.network1.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.mygetway.id
      }
    }

### Route Table Association With subnet 
resource "aws_route_table_association" "route_to_sub1" { 
   subnet_id = aws_subnet.network1_sub1.id
   route_table_id = aws_route_table.myroute1.id 
   }
  

###  Security Group 
resource  "aws_security_group"  "sg1" { 
  name  = "allow_ssh_http" 
  description = "Allow ssh and http inbound traffic" 
 vpc_id  = aws_vpc.network1.id

 ingress  { 
   description  =  "ssh from VPC"
   from_port    = 22
   to_port      = 22
   protocol     = "tcp"
   cidr_blocks  = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
   }

  egress  {
   from_port   = 0 
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]

 }
 
  tags = {
   Name = "allow_http_ssh" 
  }
 }



### Instance as webserver on RHEL9
 resource "aws_instance" "vm1"  {
     ami  =  "ami-026ebd4cfe2c043b2"
     instance_type = "t2.micro"
     associate_public_ip_address = true 
     key_name = "oct-7"
     subnet_id =  aws_subnet.network1_sub1.id
     vpc_security_group_ids = [aws_security_group.sg1.id]
     user_data = <<-EOF
      #!/bin/bash 
     sudo  dnf install httpd  -y
     echo  "Hello from  Anirudha...!"  > /var/www/html/index.html 
     sudo  systemctl restart httpd
     EOF  
     tags = { 
      Name = "Webserver1"
       }
    }
  
