# Create ses smtp user
resource "aws_iam_user" "ses_smtp" {
  name = "${var.project}-user-ses-smtp"
}

# Create ses smtp user key
resource "aws_iam_access_key" "ses_smtp" {
  user = aws_iam_user.ses_smtp.name
}

# Create policy document for ses smtp user
data "aws_iam_policy_document" "ses_smtp_ses_send_raw_email" {
  statement {
    effect    = "Allow"
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

# Attach policy to ses smtp user
resource "aws_iam_user_policy" "ses_smtp_ses_send_raw_email" {
  name   = "${var.project}-user-policy-ses-send-raw-email"
  user   = aws_iam_user.ses_smtp.name
  policy = data.aws_iam_policy_document.ses_smtp_ses_send_raw_email.json
}

# Create policy document for ecs instance role
data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create ecs instance role
resource "aws_iam_role" "ecs_instance" {
  name               = "${var.project}-role-ecs-instance"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

# Attach policy to ecs instance role
resource "aws_iam_role_policy_attachment" "ec2_container_service_for_ec2_role" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Create ecs instance profile
resource "aws_iam_instance_profile" "ecs" {
  name = "${var.project}-instance-profile-ecs-instance"
  role = aws_iam_role.ecs_instance.name
}

# Create policy document for ecs service role
data "aws_iam_policy_document" "assume_role_ecs" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

# Create ecs service role
resource "aws_iam_role" "ecs_service" {
  name               = "${var.project}-role-ecs-service"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs.json
}

# Attach policy to ecs service role
resource "aws_iam_role_policy_attachment" "ec2_container_service_role" {
  role       = aws_iam_role.ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# Create GitLab user
resource "aws_iam_user" "gitlab" {
  name = "${var.project}-user-gitlab"
}

# Create GitLab user key
resource "aws_iam_access_key" "gitlab" {
  user = aws_iam_user.gitlab.name
}

# Attach policy to GitLab user
resource "aws_iam_user_policy_attachment" "gitlab_s3_full_access" {
  user       = aws_iam_user.gitlab.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create GitLab Runner user
resource "aws_iam_user" "gitlab_runner" {
  name = "${var.project}-user-gitlab-runner"
}

# Create GitLab Runner user key
resource "aws_iam_access_key" "gitlab_runner" {
  user = aws_iam_user.gitlab_runner.name
}

# Attach policy to GitLab Runner user
resource "aws_iam_user_policy_attachment" "gitlab_runner_ec2_full_access" {
  user       = aws_iam_user.gitlab_runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Attach policy to GitLab Runner user
resource "aws_iam_user_policy_attachment" "gitlab_runner_s3_full_access" {
  user       = aws_iam_user.gitlab_runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
