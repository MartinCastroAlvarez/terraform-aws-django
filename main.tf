# -------------------------------------------------------------------------------------
# AWS settings.
# -------------------------------------------------------------------------------------
provider "aws" {
  region = "us-west-2"
}

# -------------------------------------------------------------------------------------
# AWS VPC.
# https://registry.terraform.io/providers/hashicorp/aws/3.3.0/docs/resources/vpc
# -------------------------------------------------------------------------------------
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# -------------------------------------------------------------------------------------
# AWS EIP.
# https://registry.terraform.io/providers/hashicorp/aws/2.42.0/docs/resources/eip
# -------------------------------------------------------------------------------------
resource "aws_eip" "my_nat_eip_1" {
}
resource "aws_eip" "my_nat_eip_2" {
}

# -------------------------------------------------------------------------------------
# AWS Public Subnets.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# -------------------------------------------------------------------------------------
resource "aws_subnet" "my_public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "<availability_zone_1>"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "my_public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "<availability_zone_2>"
  map_public_ip_on_launch = true
}

# -------------------------------------------------------------------------------------
# AWS Private Subnets.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# -------------------------------------------------------------------------------------
resource "aws_subnet" "my_private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "<availability_zone_1>"
}
resource "aws_subnet" "my_private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "<availability_zone_2>"
}

# -------------------------------------------------------------------------------------
# AWS IGW.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
# -------------------------------------------------------------------------------------
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# -------------------------------------------------------------------------------------
# AWS Public Route Tables.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table.html
# -------------------------------------------------------------------------------------
resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}
resource "aws_route_table_association" "my_public_subnet_1_association" {
  subnet_id      = aws_subnet.my_public_subnet_1.id
  route_table_id = aws_route_table.my_public_route_table.id
}
resource "aws_route_table_association" "my_public_subnet_2_association" {
  subnet_id      = aws_subnet.my_public_subnet_2.id
  route_table_id = aws_route_table.my_public_route_table.id
}

# -------------------------------------------------------------------------------------
# AWS NAT Gateway.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway.html
# -------------------------------------------------------------------------------------
resource "aws_nat_gateway" "my_nat_gateway_1" {
  allocation_id = aws_eip.my_nat_eip_1.id
  subnet_id     = aws_subnet.my_public_subnet_1.id
}
resource "aws_nat_gateway" "my_nat_gateway_2" {
  allocation_id = aws_eip.my_nat_eip_2.id
  subnet_id     = aws_subnet.my_public_subnet_2.id
}

# -------------------------------------------------------------------------------------
# AWS Private Route Tables.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table.html
# -------------------------------------------------------------------------------------
resource "aws_route_table" "my_private_route_table_1" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway_1.id
  }
}
resource "aws_route_table" "my_private_route_table_2" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway_2.id
  }
}
resource "aws_route_table_association" "my_private_subnet_1_association" {
  subnet_id      = aws_subnet.my_private_subnet_1.id
  route_table_id = aws_route_table.my_private_route_table_2.id
}
resource "aws_route_table_association" "my_private_subnet_2_association" {
  subnet_id      = aws_subnet.my_private_subnet_2.id
  route_table_id = aws_route_table.my_private_route_table_2.id
}

# -------------------------------------------------------------------------------------
# AWS EC2.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# -------------------------------------------------------------------------------------
resource "aws_instance" "my_ec2_1" {
  ami                    = "ami-0c94855ba95c71c99"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.my_ec2_sg.id]
  tags = {
    Name = "MyDjangoServer1"
  }
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y python3-pip python3-dev python3-venv
              apt-get install -y libpq-dev

              # Create and activate a virtual environment
              python3 -m venv myenv
              source myenv/bin/activate

              # Install Django and other dependencies
              pip install django gunicorn psycopg2-binary

              # Clone your Django application from a repository
              git clone <repository_url> myapp

              # Install the application requirements
              pip install -r myapp/requirements.txt

              # Migrate the database
              cd myapp
              python manage.py migrate

              # Collect static files
              python manage.py collectstatic --noinput

              # Start the Gunicorn server
              gunicorn myapp.wsgi:application --bind 0.0.0.0:8000
            EOF 
}
resource "aws_instance" "my_ec2_2" {
  ami                    = "ami-0c94855ba95c71c99"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.my_ec2_sg.id]
  tags = {
    Name = "MyDjangoServer2"
  }
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y python3-pip python3-dev python3-venv
              apt-get install -y libpq-dev

              # Create and activate a virtual environment
              python3 -m venv myenv
              source myenv/bin/activate

              # Install Django and other dependencies
              pip install django gunicorn psycopg2-binary

              # Clone your Django application from a repository
              git clone <repository_url> myapp

              # Install the application requirements
              pip install -r myapp/requirements.txt

              # Migrate the database
              cd myapp
              python manage.py migrate

              # Collect static files
              python manage.py collectstatic --noinput

              # Start the Gunicorn server
              gunicorn myapp.wsgi:application --bind 0.0.0.0:8000
            EOF 
}
resource "aws_security_group" "my_ec2_sg" {
  name        = "ec2_sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "my_ec2_1_ip" {
  value = aws_instance.my_ec2_1.public_ip
}
output "my_ec2_2_ip" {
  value = aws_instance.my_ec2_2.public_ip
}

# -------------------------------------------------------------------------------------
# AWS ELB.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
# -------------------------------------------------------------------------------------
resource "aws_elb" "my_elb" {
  name            = "my-elb"
  security_groups = [aws_security_group.my_elb_sg.id]
  subnets         = [aws_subnet.my_public_subnet_1.id, aws_subnet.my_public_subnet_2.id]
  instances       = [aws_instance.my_ec2_1.id, aws_instance.my_ec2_1.id]
  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  listener {
    instance_port     = 442
    instance_protocol = "HTTPS"
    lb_port           = 443
    lb_protocol       = "HTTPS"
  }
}
resource "aws_security_group" "my_elb_sg" {
  name        = "ec2_sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "my_elb_dns_name" {
  value = aws_elb.my_elb.dns_name
}

# -------------------------------------------------------------------------------------
# AWS RDS.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
# -------------------------------------------------------------------------------------
resource "aws_db_subnet_group" "my_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.my_private_subnet_1.id, aws_subnet.my_private_subnet_2.id]
  tags = {
    Name = "MyDatabaseSubnetGroup"
  }
}
resource "aws_db_instance" "my_db" {
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  identifier             = "my-rds-instance"
  username               = "admin"
  password               = "password"
  db_subnet_group_name   = aws_db_subnet_group.my_subnet_group.name
  vpc_security_group_ids = [aws_security_group.my_db.id]
  availability_zone      = "<availability_zone_1>"
  publicly_accessible    = false
  multi_az               = true
}
resource "aws_security_group" "my_db" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "my_db_endpoint" {
  value = aws_db_instance.my_db.endpoint
}