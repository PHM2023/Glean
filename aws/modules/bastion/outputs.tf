
output "bastion_instance_id" {
  # We add these dependencies so this output can only be used once both the bastion ssm agent is online and it can talk
  # to the eks cluster. The reverse is true too: we only want to destroy the ingress rule above after every resource
  # that needs bastion has already been destroyed.
  depends_on = [null_resource.ssm_readiness_check, aws_vpc_security_group_ingress_rule.eks_bastion_ingress_allow]
  value      = aws_instance.bastion.id
}
