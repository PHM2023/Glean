resource "aws_security_group" "elasticache_security_group" {
  name        = "elasticache-security-group"
  description = "For access to the elasticache cluster from eks pods"
  vpc_id      = var.elasticache_vpc_id
}

# Allow EKS workloads to talk to the memcached cluster. Note we're intentionally doing it this way so that the
# elasticache cluster can be created in parallel to this resource (and therefore, in parallel to the EKS cluster).
# The alternative would be to include this rule in the resource above directly, but that would implicitly make the
# elasticache cluster below dependent on the EKS cluster, which is unnecessary.
resource "aws_security_group_rule" "allow_eks_elasticache_access" {
  from_port                = 11211
  protocol                 = "tcp"
  to_port                  = 11211
  source_security_group_id = var.eks_security_group_id
  security_group_id        = aws_security_group.elasticache_security_group.id
  type                     = "ingress"
}


resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "glean-subnet-group"
  subnet_ids = [var.eks_private_subnet_id]
}

resource "aws_elasticache_cluster" "memcached_cluster" {
  cluster_id         = "glean-global-memcached"
  engine             = "memcached"
  node_type          = var.elasticache_cluster_node_type
  num_cache_nodes    = var.elasticache_num_nodes
  engine_version     = var.elasticache_memcached_version
  subnet_group_name  = aws_elasticache_subnet_group.elasticache_subnet_group.name
  security_group_ids = [aws_security_group.elasticache_security_group.id]
}
