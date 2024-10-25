# The default nodegroup limit is 30/cluster, which is too low for us. So before adding any new groups, we have to submit
# quota increase request. Bumping the limit to 45 generally gets automatic approval, so there's no need to manually
# wait for the quota to update. Due to this constraint though, every nodegroup listed in here should be dependent on
# this request.

data "aws_servicequotas_service" "eks_servicequota_service" {
  service_name = "Amazon Elastic Kubernetes Service (Amazon EKS)"
}

data "aws_servicequotas_service_quota" "eks_nodegroups_per_cluster_service_quota" {
  quota_name   = "Managed node groups per cluster"
  service_code = data.aws_servicequotas_service.eks_servicequota_service.service_code
}

resource "aws_servicequotas_service_quota" "eks_nodegroups_per_cluster_service_quota" {
  quota_code   = data.aws_servicequotas_service_quota.eks_nodegroups_per_cluster_service_quota.quota_code
  service_code = data.aws_servicequotas_service.eks_servicequota_service.service_code
  # Ensures we don't accidentally lower the quota than what it's already set at - terraform fails if we try lowering it
  # anyway
  value = max(45, data.aws_servicequotas_service_quota.eks_nodegroups_per_cluster_service_quota.value)
}

module "nodegroup_configs" {
  source              = "./read_config"
  region              = var.region
  account_id          = var.account_id
  keys                = local.full_standalone_nodegroup_config_keys
  default_config_path = var.default_config_path
  custom_config_path  = var.custom_config_path
}

### DEPLOY JOB NODEGROUP ###
module "deploy_job_nodegroup" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "deploy-job-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  # Keep the desired/min size relatively high so no deploy jobs are waiting too long to be scheduled
  desired_size = 1
  min_size     = 1
  max_size     = 20
  taints = [{
    key    = "service"
    value  = "glean-deploy-jobs"
    effect = "NO_SCHEDULE"
  }]
  disk_size_gi  = 100
  instance_type = "t3.xlarge"
  depends_on    = [aws_servicequotas_service_quota.eks_nodegroups_per_cluster_service_quota]
}
#################################

module "autoscaler_node_group" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "autoscaler-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 1
  max_size        = 1
  desired_size    = 1
  taints = [{
    key = "autoscaler"
    # we can't use true/false here because adding 'true' to the tolerations on the helm installation below doesn't seem
    # to work
    value  = "true"
    effect = "NO_SCHEDULE"
  }]
  labels = {
    autoscaler = "true"
  }
  # See the comment in terraform/glean.com/aws/modules/eks_phase_1/cluster.tf for why we have to set these values to
  # null on this group and the below ones
  instance_type = null
  disk_size_gi  = null
  # We put explicit dependencies on node groups to avoid iam throttling
  # The order would be [deploy_job_nodegroup, autoscaler_node_group]
  depends_on = [module.deploy_job_nodegroup]
}


module "alb_node_group" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "alb-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 1
  max_size        = 1
  desired_size    = 1
  taints = [{
    key = "alb"
    # we can't use true/false here because adding 'true' to the tolerations on the helm installation below doesn't seem
    # to work
    value  = "enabled"
    effect = "NO_SCHEDULE"
  }]
  labels = {
    alb = "enabled"
  }
  instance_type = null
  disk_size_gi  = null
  # We put explicit dependencies on node groups to avoid iam throttling
  # The order would be [autoscaler_node_group, alb_node_group]
  depends_on = [module.autoscaler_node_group]
}


module "cron_job_node_group" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "cron-job-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 2
  max_size        = 20
  desired_size    = 2
  taints = [{
    key = "cron-job"
    # we can't use true/false here because adding 'true' to the tolerations on the helm installation below doesn't seem
    # to work
    value  = "enabled"
    effect = "NO_SCHEDULE"
  }]
  labels = {
    cron-job : "enabled"
    "glean.com/node-pool-selector" : "cron-job-nodegroup"
  }
  instance_type = null
  disk_size_gi  = null
  # We put explicit dependencies on node groups to avoid iam throttling
  # The order would be [autoscaler_node_group, alb_node_group, rabbitmq_nodegroup, task_push_nodegroup, crawler_nodegroup, cron_job_node_group]
  depends_on = [module.crawler_nodegroup]
}

module "rabbitmq_nodegroup" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "rabbitmq-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 0
  max_size        = 50
  desired_size    = 1
  taints = [{
    key    = "service"
    value  = "rabbitmq"
    effect = "NO_SCHEDULE"
  }]
  labels = {
    "glean.com/node-pool-selector" : "rabbitmq-nodegroup"
  }
  instance_type = local.rabbitmq_machine_type
  # Note: technically this disk size config is way over-provisioned because the PVC can use a different volume than the
  # ones created by the launch template - this size is only meant for the boot data disk size of rabbitmq, but not the
  # entire queues state. Again, this was how we were doing it before in python, so we're just being consistent until
  # we can upgrade to new nodegroups
  disk_size_gi = local.rabbitmq_disk_size_gi + 20 # Add 20GB for overhead
  # TODO: remove these and migrate rabbitmq to a new nodegroup with the correct configs
  _do_not_use_for_new_nodegroups_port_from_python_created_nodegroup                 = true
  _do_not_use_for_new_nodegroups_defined_volume_tag_specs_before_instance_tag_specs = contains(var._launch_templates_with_volume_tags_defined_first, "rabbitmq-nodegroup-launch-template")
  # We put explicit dependencies on node groups to avoid iam throttling
  # The order would be [autoscaler_node_group, alb_node_group, rabbitmq_nodegroup]
  depends_on = [module.alb_node_group]
}

module "task_push_nodegroup" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "task-push-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 0
  max_size        = 50
  desired_size    = 1
  taints = [{
    key    = "service"
    value  = "task-push"
    effect = "NO_SCHEDULE"
  }]
  labels = {
    "glean.com/node-pool-selector" : "task-push-nodegroup"
  }
  instance_type = local.nodegroup_configs.task_push_machine_type
  disk_size_gi  = local.nodegroup_configs.disk_size_gi
  # TODO: remove these and migrate task-push to a new nodegroup with the correct configs
  _do_not_use_for_new_nodegroups_port_from_python_created_nodegroup                 = true
  _do_not_use_for_new_nodegroups_defined_volume_tag_specs_before_instance_tag_specs = contains(var._launch_templates_with_volume_tags_defined_first, "task-push-nodegroup-launch-template")
  # We put explicit dependencies on node groups to avoid iam throttling
  # The order would be [autoscaler_node_group, alb_node_group, rabbitmq_nodegroup, task_push_nodegroup]
  depends_on = [module.rabbitmq_nodegroup]
}

module "crawler_nodegroup" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "crawler-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 0
  max_size        = 50
  desired_size    = 1
  labels = {
    "glean.com/node-pool-selector" : "crawler-nodegroup"
  }
  instance_type = local.nodegroup_configs.crawler_machine_type
  disk_size_gi  = local.nodegroup_configs.disk_size_gi
  # TODO: remove these and migrate task-push to a new nodegroup with the correct configs
  _do_not_use_for_new_nodegroups_port_from_python_created_nodegroup                 = true
  _do_not_use_for_new_nodegroups_defined_volume_tag_specs_before_instance_tag_specs = contains(var._launch_templates_with_volume_tags_defined_first, "crawler-nodegroup-launch-template")
  # We put explicit dependencies on node groups to avoid iam throttling
  # The order would be [autoscaler_node_group, alb_node_group, rabbitmq_nodegroup, task_push_nodegroup, crawler_nodegroup]
  depends_on = [module.task_push_nodegroup]
}

# Node groups for the memory-based k8s apps - all of the relevant deployments share these and choose the smallest one
# that can accommodate the requirements using node affinity.
# NOTE: we're intentionally not defining these using for_each so we don't run into quota issues for creating too many
# node groups at once
module "memory_based_small_nodegroup" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "memory-based-small-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 0
  max_size        = 50
  desired_size    = 0
  taints          = local.memory_based_nodegroup_taints
  labels = {
    (local.memory_based_nodegroup_selector_key) : local.memory_based_nodegroup_selector_value
  }
  instance_type = local.nodegroup_configs.memory_based_instance_types["small"]
  disk_size_gi  = local.nodegroup_configs.disk_size_gi
  depends_on    = [module.crawler_nodegroup]
}

module "memory_based_medium_nodegroup" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "memory-based-medium-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 0
  max_size        = 50
  desired_size    = 0
  taints          = local.memory_based_nodegroup_taints
  labels = {
    (local.memory_based_nodegroup_selector_key) : local.memory_based_nodegroup_selector_value
  }
  instance_type = local.nodegroup_configs.memory_based_instance_types["medium"]
  disk_size_gi  = local.nodegroup_configs.disk_size_gi
  # Again, these have to be created sequentially to not hit eks 429s
  depends_on = [module.memory_based_small_nodegroup]
}

module "memory_based_large_nodegroup" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "memory-based-large-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 0
  max_size        = 50
  desired_size    = 0
  taints          = local.memory_based_nodegroup_taints
  labels = {
    (local.memory_based_nodegroup_selector_key) : local.memory_based_nodegroup_selector_value
  }
  instance_type = local.nodegroup_configs.memory_based_instance_types["large"]
  disk_size_gi  = local.nodegroup_configs.disk_size_gi
  # Again, these have to be created sequentially to not hit eks 429s
  depends_on = [module.memory_based_medium_nodegroup]
}

module "memory_based_xlarge_nodegroup" {
  source          = "../../modules/eks_node_group_v2"
  node_group_name = "memory-based-xlarge-nodegroup"
  cluster_name    = module.eks_phase_1.cluster_name
  node_role_arn   = module.eks_phase_1.worker_node_arn
  subnet_ids      = [module.network.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 0
  max_size        = 50
  desired_size    = 0
  taints          = local.memory_based_nodegroup_taints
  labels = {
    (local.memory_based_nodegroup_selector_key) : local.memory_based_nodegroup_selector_value
  }
  instance_type = local.nodegroup_configs.memory_based_instance_types["xlarge"]
  disk_size_gi  = local.nodegroup_configs.disk_size_gi
  # Again, these have to be created sequentially to not hit eks 429s
  depends_on = [module.memory_based_large_nodegroup]
}
