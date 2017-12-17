# Create db subnet group
resource "aws_db_subnet_group" "private" {
  name       = "${var.project}-subnet-group"
  subnet_ids = ["${aws_subnet.private.*.id}"]
}

# Create random id for GitLab db password
resource "random_string" "gitlab_db_password" {
  length = 10
}

# Create GitLab RDS
resource "aws_db_instance" "gitlab" {
  identifier             = "${var.project}-gitlab"
  engine                 = "postgres"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  multi_az               = true
  username               = "gitlab"
  password               = "${random_string.gitlab_db_password.result}"
  name                   = "gitlabhq_production"
  db_subnet_group_name   = "${aws_db_subnet_group.private.id}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  skip_final_snapshot    = true
}

# Create random id for Mattermost db password
resource "random_string" "mattermost_db_password" {
  length = 10
}

# Create Mattermost RDS
resource "aws_db_instance" "mattermost" {
  identifier             = "${var.project}-mattermost"
  engine                 = "postgres"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  multi_az               = true
  username               = "gitlab_mattermost"
  password               = "${random_string.mattermost_db_password.result}"
  name                   = "mattermost_production"
  db_subnet_group_name   = "${aws_db_subnet_group.private.id}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  skip_final_snapshot    = true
}
