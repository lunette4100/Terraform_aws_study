resource "aws_cloudwatch_log_group" "tf_cloudwatch_logs" {
  name                        = "aws-waf-logs-tf-cloudwatch-logs"
  deletion_protection_enabled = true
  retention_in_days           = 3
  log_group_class             = "STANDARD"
}
resource "aws_wafv2_web_acl_logging_configuration" "tf_cloudwatch_logs_cf" {
  log_destination_configs = [aws_cloudwatch_log_group.tf_cloudwatch_logs.arn]
  resource_arn            = aws_wafv2_web_acl.tf_waf.arn

}