resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count               = "${length(var.alarm_topic)>0?1:0}"
  alarm_name          = "${var.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "120"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "${var.function_name} has errors"

  dimensions {
    Resource     = "${var.function_name}"
    FunctionName = "${var.function_name}"
  }

  alarm_actions = ["${var.alarm_topic}"]
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  count               = "${length(var.alarm_topic)>0?1:0}"
  alarm_name          = "${var.function_name}-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "120"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "${var.function_name} has errors"

  dimensions {
    Resource     = "${var.function_name}"
    FunctionName = "${var.function_name}"
  }

  alarm_actions = ["${var.alarm_topic}"]
}
