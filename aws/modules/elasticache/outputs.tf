output "discovery_endpoint" {
  value = aws_elasticache_cluster.memcached_cluster.configuration_endpoint
  # Ensures that the discovery endpoint isn't actually used until it can accessed from the EKS cluster
  depends_on = [aws_security_group_rule.allow_eks_elasticache_access]
}
