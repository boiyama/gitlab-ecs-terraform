# Create ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-ecs"
}

# Get GitLab config
data "template_file" "gitlab_config" {
  template = "${file("${path.module}/templates/gitlab/gitlab-config.rb")}"

  vars {
    gitlab_host                   = "${var.hosts[1]}${var.domain_name}"
    gitlab_ssh_host               = "${var.hosts[2]}${var.domain_name}"
    access_key                    = "${aws_iam_access_key.gitlab.id}"
    secret_key                    = "${aws_iam_access_key.gitlab.secret}"
    region                        = "${data.aws_region.current.name}"
    bucket_name                   = "${aws_s3_bucket.gitlab_backup.id}"
    db_password                   = "${random_string.gitlab_db_password.result}"
    db_host                       = "${aws_db_instance.gitlab.address}"
    redis_host                    = "${aws_elasticache_cluster.gitlab.cache_nodes.0.address}"
    smtp_user_name                = "${aws_iam_access_key.ses_smtp.id}"
    smtp_password                 = "${aws_iam_access_key.ses_smtp.ses_smtp_password}"
    smtp_address                  = "email-smtp.${data.aws_region.current.name}.amazonaws.com"
    pages_host                    = "${substr(var.hosts[3], 2, -1)}${var.domain_name}"
    registry_host                 = "${var.hosts[4]}${var.domain_name}"
    mattermost_host               = "${var.hosts[5]}${var.domain_name}"
    mattermost_db_password        = "${random_string.mattermost_db_password.result}"
    mattermost_db_host            = "${aws_db_instance.mattermost.address}"
    webrtc_gateway_admin_host     = "${var.hosts[6]}${var.domain_name}"
    webrtc_gateway_websocket_host = "${var.hosts[7]}${var.domain_name}"
  }
}

# Create random id for GitLab runner token
resource "random_string" "gitlab_runner_token" {
  length  = 20
  special = false
}

# Create random id for GitLab root password
resource "random_string" "gitlab_root_password" {
  length  = 10
  special = false
}

# Get each task definition json
data "template_file" "container_definitions" {
  count    = "${length(var.container_names)}"
  template = "${file("${path.module}/templates/${var.container_names[count.index]}/container_definitions.json")}"

  vars {
    name          = "${var.container_names[count.index]}"
    awslogs_group = "${element(aws_cloudwatch_log_group.container.*.name, count.index)}"
    gitlab_config = "${var.container_names[count.index] == "gitlab" ? replace(replace(data.template_file.gitlab_config.rendered, "/#.*\n/", ""), "/\n/", "\\n") : ""}"
    runner_token  = "${var.container_names[count.index] == "gitlab" ? random_string.gitlab_runner_token.result : ""}"
    root_password = "${var.container_names[count.index] == "gitlab" ? random_string.gitlab_root_password.result : ""}"
  }
}

# Create each task definitions
resource "aws_ecs_task_definition" "main" {
  count                 = "${length(var.container_names)}"
  family                = "${var.project}-ecs-td-${var.container_names[count.index]}"
  container_definitions = "${element(data.template_file.container_definitions.*.rendered, count.index)}"
  task_role_arn         = "${aws_iam_role.ecs_service.arn}"

  volume {
    name      = "main"
    host_path = "/mnt/efs/${var.container_names[count.index]}"
  }

  volume {
    name      = "gitlab-etc"
    host_path = "${var.container_names[count.index] == "gitlab" ? "/mnt/efs/gitlab/etc/gitlab" : ""}"
  }

  volume {
    name      = "gitlab-log"
    host_path = "${var.container_names[count.index] == "gitlab" ? "/mnt/efs/gitlab/var/log/gitlab" : ""}"
  }

  volume {
    name      = "gitlab-opt"
    host_path = "${var.container_names[count.index] == "gitlab" ? "/mnt/efs/gitlab/var/opt/gitlab" : ""}"
  }
}

# Create each services with ALB
resource "aws_ecs_service" "with_alb" {
  count                              = "${length(var.http_containers)}"
  name                               = "${var.project}-ecs-service-${lookup(var.http_containers[count.index], "container_name")}-${lookup(var.http_containers[count.index], "container_port")}"
  cluster                            = "${aws_ecs_cluster.main.id}"
  task_definition                    = "${element(aws_ecs_task_definition.main.*.arn, index(var.container_names, lookup(var.http_containers[count.index], "container_name")))}"
  desired_count                      = "${lookup(var.http_containers[count.index], "desired_count")}"
  deployment_minimum_healthy_percent = 50
  iam_role                           = "${aws_iam_role.ecs_service.name}"

  load_balancer {
    target_group_arn = "${element(aws_alb_target_group.ecs.*.id, count.index)}"
    container_name   = "${lookup(var.http_containers[count.index], "container_name")}"
    container_port   = "${lookup(var.http_containers[count.index], "container_port")}"
  }
}

# Create each services without LB
resource "aws_ecs_service" "without_lb" {
  count                              = "${length(var.private_containers)}"
  name                               = "${var.project}-ecs-service-${lookup(var.private_containers[count.index], "container_name")}"
  cluster                            = "${aws_ecs_cluster.main.id}"
  task_definition                    = "${element(aws_ecs_task_definition.main.*.arn, index(var.container_names, lookup(var.private_containers[count.index], "container_name")))}"
  desired_count                      = "${lookup(var.private_containers[count.index], "desired_count")}"
  deployment_minimum_healthy_percent = 50
}
