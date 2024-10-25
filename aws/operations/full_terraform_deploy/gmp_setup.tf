
###################### BEGIN GMP Collector ######################
# Role definition
resource "aws_iam_role" "gmp_collector_role" {
  name                 = "GoogleManagedPrometheusCollectorRole"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.account_id}:oidc-provider/${module.eks_phase_1.oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:gmp-system:gmp-collector",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns  = local.core_permission_policies
}
