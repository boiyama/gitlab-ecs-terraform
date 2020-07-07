# Get user data
data "template_file" "ecs_user_data" {
  template = "${file("${path.module}/templates/ecs-instance/user_data.sh")}"

  vars = {
    efs_id      = "${aws_efs_file_system.main.id}"
    ecs_cluster = "${aws_ecs_cluster.main.name}"
  }
}

# Create Launch Configuration
resource "aws_launch_configuration" "ecs" {
  name_prefix          = "${var.project}-lc-"
  image_id             = data.aws_ami.amazon_ecs_optimized.id
  instance_type        = var.instance_type
  spot_price           = var.spot_price
  user_data            = data.template_file.ecs_user_data.rendered
  key_name             = aws_key_pair.main.key_name
  security_groups      = [aws_security_group.instance.id]
  iam_instance_profile = aws_iam_instance_profile.ecs.name

  lifecycle {
    create_before_destroy = true
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "ecs" {
  depends_on           = [aws_efs_mount_target.main]
  name                 = "${var.project}-asg"
  launch_configuration = aws_launch_configuration.ecs.name
  vpc_zone_identifier  = [join("\",\"", aws_subnet.private.*.id)]

  min_size         = var.autoscaling_min
  max_size         = var.autoscaling_max
  desired_capacity = var.autoscaling_desired

  tag {
    key                 = "Name"
    value               = "${var.project}-instance-ecs"
    propagate_at_launch = true
  }
}
