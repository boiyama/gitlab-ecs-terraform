variable "project" {
  default = "devtools"
}

variable "cidr_block" {
  default = "10.255.0.0/16"
}

variable "instance_type" {
  default = "t3a.medium"
}

variable "spot_price" {
  default = 0.1
}

variable "autoscaling_min" {
  default = 1
}

variable "autoscaling_max" {
  default = 1
}

variable "autoscaling_desired" {
  default = 1
}

variable "container_names" {
  default = ["portal", "gitlab", "gitlab-runner", "janus", "janus-ws"]
}

variable "http_containers" {
  default = [
    {
      container_name    = "portal"
      container_port    = 80
      health_check_path = "/"
      health_check_port = "traffic-port"
      desired_count     = 1
    },
    {
      container_name    = "gitlab"
      container_port    = 80
      health_check_path = "/help"
      health_check_port = "traffic-port"
      desired_count     = 1
    },
    {
      container_name    = "janus"
      container_port    = 7088
      health_check_path = "/admin"
      health_check_port = "traffic-port"
      desired_count     = 1
    },
    {
      container_name    = "janus-ws"
      container_port    = 8188
      health_check_path = "/admin"
      health_check_port = 7088
      desired_count     = 1
    },
  ]
}

# variable "ssh_containers" {
#   default = [
#     {
#       container_name = "gitlab"
#       container_port = 22
#       desired_count  = 1
#     },
#   ]
# }

variable "private_containers" {
  default = [
    {
      container_name = "gitlab-runner"
      desired_count  = 1
    },
  ]
}

variable "domain_name" {
  default = "example.com"
}

variable "additional_names" {
  default = [
    "*.",
    "*.pages.gitlab.",
  ]
}

variable "hosts" {
  default = [
    "",
    "gitlab.",
    "ssh.gitlab.",
    "*.pages.gitlab.",
    "registry.gitlab.",
    "mattermost.",
    "janus.",
    "janus-ws.",
  ]
}

variable "cloudfront_hosts" {
  default = [
    "",
    "*.pages.gitlab.",
    "registry.gitlab.",
    "janus.",
  ]
}

variable "alb_hosts" {
  default = [
    "gitlab.",
    "mattermost.",
    "janus-ws.",
  ]
}

variable "nlb_hosts" {
  default = [
    "ssh.gitlab.",
  ]
}

variable "host_http_target_mappings" {
  default = [
    {
      host               = "gitlab."
      target_group_index = 1
    },
    {
      host               = "*.pages.gitlab."
      target_group_index = 1
    },
    {
      host               = "registry.gitlab."
      target_group_index = 1
    },
    {
      host               = "mattermost."
      target_group_index = 1
    },
    {
      host               = "janus."
      target_group_index = 2
    },
    {
      host               = "janus-ws."
      target_group_index = 3
    },
  ]
}

# variable "host_ssh_target_mappings" {
#   default = [
#     {
#       host               = "ssh.gitlab."
#       target_group_index = 0
#     },
#   ]
# }

