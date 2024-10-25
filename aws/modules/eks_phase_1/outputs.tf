output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "worker_node_arn" {
  value = aws_iam_role.eks_worker_node.arn
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.glean_cluster.vpc_config[0].cluster_security_group_id
}

# The core addons should be present before any of the following attributes in the cluster are used

output "cluster_name" {
  value = aws_eks_cluster.glean_cluster.name
  depends_on = [
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.ebs_csi_driver,
    aws_eks_addon.vpc_cni,
    aws_iam_openid_connect_provider.oidc_provider
  ]
}

output "cluster_endpoint" {
  value = aws_eks_cluster.glean_cluster.endpoint
  depends_on = [
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.ebs_csi_driver,
    aws_eks_addon.vpc_cni,
    aws_iam_openid_connect_provider.oidc_provider
  ]
}

output "cluster_ca_cert_data" {
  value = aws_eks_cluster.glean_cluster.certificate_authority[0].data
  depends_on = [
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.ebs_csi_driver,
    aws_eks_addon.vpc_cni,
    aws_iam_openid_connect_provider.oidc_provider
  ]
}

output "oidc_provider" {
  value = local.oidc_provider
  depends_on = [
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.ebs_csi_driver,
    aws_eks_addon.vpc_cni,
    aws_iam_openid_connect_provider.oidc_provider
  ]
}

output "cluster_audit_log_name" {
  value = aws_cloudwatch_log_group.cluster_audit_logs.name
}