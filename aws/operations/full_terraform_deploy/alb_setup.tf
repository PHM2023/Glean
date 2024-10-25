
data "http" "alb_policy_contents" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json"
}


resource "aws_iam_policy" "alb_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for alb controller within eks cluster"
  policy      = data.http.alb_policy_contents.body
}

resource "aws_iam_role" "alb_role" {
  name                 = "AmazonEKSLoadBalancerControllerRole"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${module.eks_phase_1.oidc_provider}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.eks_phase_1.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks_phase_1.oidc_provider}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.alb_policy.arn]
}
