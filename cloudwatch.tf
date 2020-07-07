resource "aws_cloudwatch_log_group" "container" {
  count = length(var.container_names)
  name  = "${var.project}/${var.container_names[count.index]}"
}

# resource "aws_cloudwatch_log_group" "gitlab" {
#   name = "${var.project}/gitlab"
# }

