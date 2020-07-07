# Create security groups
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project}-sg-alb"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-sg-alb"
  }
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project}-sg-instance"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.cidr_block}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-sg-instance"
  }
}

resource "aws_security_group" "efs" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project}-sg-efs"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.cidr_block}"]
  }

  tags = {
    Name = "${var.project}-sg-efs"
  }
}

resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project}-sg-rds"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.cidr_block}"]
  }

  tags = {
    Name = "${var.project}-sg-rds"
  }
}

resource "aws_security_group" "elasticache" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project}-sg-elasticache"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.cidr_block}"]
  }

  tags = {
    Name = "${var.project}-sg-elasticache"
  }
}

resource "aws_security_group" "gitlab_runner" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project}-sg-gitlab-runner"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 2376
    to_port     = 2376
    cidr_blocks = ["${var.cidr_block}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-sg-gitlab-runner"
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project}-sg-bastion"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-sg-bastion"
  }
}
