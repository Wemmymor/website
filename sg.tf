# Create Security Group for the Application Load Balancer
# terraform aws create security group
resource "aws_security_group" "alb-sg" {
  name        = "ALB-sg"
  description = "Allow http/https access on port 80/443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB SG"
  }
}

# Create Security Group for the Bastion Host aka Jump Box
# terraform aws create security group
resource "aws_security_group" "ssh-sg" {
  name        = "SSH-Access"
  description = "Allow ssh access on port 22"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.ssh-location}"]  # limit this to your IP in prod environment (best-practice)
  }
 
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH SG"
  }
}

# Create Security Group for the Web Server
# terraform aws create security group
resource "aws_security_group" "Web-Server-SG" {
  name        = "Web-Server-SG"
  description = "Allow http/https on port 80/443 via ALB and SSH on port 22 via SSH SG"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups    = ["${aws_security_group.alb-sg.id}"]
  }

  ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups    = ["${aws_security_group.alb-sg.id}"]
  }

    ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups      = ["${aws_security_group.ssh-sg.id}"]
  }
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebServer SG"
  }
}

# Create Security Group for the Database
# terraform aws create security group
resource "aws_security_group" "DB-sg" {
  name        = "DB-SG"
  description = "Allow MYSQL/AURORA access on port 3306"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "MYSQL/AURORA access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups      = ["${aws_security_group.Web-Server-SG.id}"]
  }
 
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DB SG"
  }
}
