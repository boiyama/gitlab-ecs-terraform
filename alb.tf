# Create ALB
resource "aws_alb" "main" {
  name            = "${var.project}-alb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.alb.id}"]
}

resource "aws_alb_target_group" "ecs" {
  count    = "${length(var.http_containers)}"
  name     = "${var.project}-tg-${lookup(var.http_containers[count.index], "container_name")}-${lookup(var.http_containers[count.index], "container_port")}"
  vpc_id   = "${aws_vpc.main.id}"
  port     = "${lookup(var.http_containers[count.index], "container_port")}"
  protocol = "HTTP"

  health_check {
    path                = "${lookup(var.http_containers[count.index], "health_check_path")}"
    port                = "${lookup(var.http_containers[count.index], "health_check_port")}"
    interval            = 60
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = 80

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs.0.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_cloudformation_stack.cert.outputs["Arn"]}"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs.0.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "http" {
  count        = "${length(var.host_http_target_mappings)}"
  listener_arn = "${aws_alb_listener.http.arn}"
  priority     = "${count.index + 1}"

  action {
    type             = "forward"
    target_group_arn = "${element(aws_alb_target_group.ecs.*.id, lookup(var.host_http_target_mappings[count.index], "target_group_index"))}"
  }

  condition {
    field  = "host-header"
    values = ["${lookup(var.host_http_target_mappings[count.index], "host")}${var.domain_name}"]
  }
}

resource "aws_alb_listener_rule" "https" {
  count        = "${length(var.host_http_target_mappings)}"
  listener_arn = "${aws_alb_listener.https.arn}"
  priority     = "${count.index + 1}"

  action {
    type             = "forward"
    target_group_arn = "${element(aws_alb_target_group.ecs.*.id, lookup(var.host_http_target_mappings[count.index], "target_group_index"))}"
  }

  condition {
    field  = "host-header"
    values = ["${lookup(var.host_http_target_mappings[count.index], "host")}${var.domain_name}"]
  }
}
