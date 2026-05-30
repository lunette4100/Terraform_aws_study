resource "aws_cloudwatch_metric_alarm" "alarm_ec2" {
  alarm_name          = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions = [var.cloudwatch_alarm]

  ok_actions = [var.cloudwatch_alarm]
  dimensions = {
    InstanceId = aws_instance.tf_ec2.id
  }
}

