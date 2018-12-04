resource "aws_cloudwatch_event_rule" "task_runner_scheduler" {
  name                = "${var.prefix}-${var.function_name}"
  description         = "${var.prefix}-${var.function_name}-schedule"
  schedule_expression = "${var.schedule_expression}"
}

/**
 * Target the lambda function with the schedule.
 */
resource "aws_cloudwatch_event_target" "call_task_runner_scheduler" {
  count     = "${var.schedule_expression!=""?1:0}"
  rule      = "${aws_cloudwatch_event_rule.task_runner_scheduler.name}"
  target_id = "${var.prefix}-${var.function_name}-schedule-lambda"

  arn = "${aws_lambda_function.func.arn}"

  #input = "${var.lambda_}"
}
