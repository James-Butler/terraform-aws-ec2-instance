# Restart dead or hung instance

resource "null_resource" "check_alarm_action" {
  count = local.cloudwatch_alarm_action_enabled ? 1 : 0

  triggers = {
    action = "arn:${data.aws_partition.default.partition}:swf:${local.region}:${data.aws_caller_identity.default.account_id}:${local.default_alarm_action}"
  }
}

resource "aws_cloudwatch_metric_alarm" "default" {
  count               = local.instance_count
  alarm_name          = module.this.id
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.metric_namespace
  period              = var.applying_period
  statistic           = var.statistic_level
  threshold           = var.metric_threshold
  depends_on          = [null_resource.check_alarm_action]

  dimensions = {
    InstanceId = join("", aws_instance.default.*.id)
  }

  alarm_actions = local.cloudwatch_alarm_action_enabled ? [
    null_resource.check_alarm_action[count.index].triggers.action
  ] : []
}
