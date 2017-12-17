resource "aws_elasticache_subnet_group" "private" {
  name       = "${var.project}-subnet-group"
  subnet_ids = ["${aws_subnet.private.*.id}"]
}

# Create GitLab elasticache cluster
resource "aws_elasticache_cluster" "gitlab" {
  cluster_id           = "${var.project}-gitlab"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  port                 = 6379
  subnet_group_name    = "${aws_elasticache_subnet_group.private.name}"
  security_group_ids   = ["${aws_security_group.elasticache.id}"]
}
