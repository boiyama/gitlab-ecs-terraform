output "bastion_id" {
  value = "${aws_instance.bastion.id}"
}

output "bastion_ip" {
  value = "${aws_eip.bastion.public_ip}"
}

output "gitlab_root_password" {
  value = "${random_string.gitlab_root_password.result}"
}

# Get GitLab Runner register commnad
data "template_file" "gitlab_runner_register" {
  template = "${file("${path.module}/templates/gitlab-runner/register.sh")}"

  vars {
    project        = "${var.project}"
    gitlab_host    = "${var.hosts[1]}${var.domain_name}"
    runner_token   = "${random_string.gitlab_runner_token.result}"
    access_key     = "${aws_iam_access_key.gitlab_runner.id}"
    secret_key     = "${aws_iam_access_key.gitlab_runner.secret}"
    region         = "${data.aws_region.current.name}"
    vpc_id         = "${aws_vpc.main.id}"
    subnet_id      = "${aws_subnet.private.0.id}"
    security_group = "${aws_security_group.gitlab_runner.name}"
    bucket_name    = "${aws_s3_bucket.gitlab_runner.id}"
  }
}

output "gitlab_runner_register" {
  value = "${replace(data.template_file.gitlab_runner_register.rendered, "/\n/", " ")}"
}

output "gitlab_runner_unregister" {
  value = "${replace(file("${path.module}/templates/gitlab-runner/unregister.sh"), "/\n/", " ")}"
}
