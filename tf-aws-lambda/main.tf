resource "aws_lambda_permission" "allow_resource" {
  count         = "${length(var.resource_arn)>0?1:0}"
  statement_id  = "AllowExecutionFromResource"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.func.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.resource_arn}"
}

resource "aws_lambda_function" "func" {
  filename         = "${data.archive_file.lambda_zip.output_path}"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name    = "${var.function_name}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "${var.handler}"
  description      = "${var.description}"
  runtime          = "${var.runtime}"
  memory_size      = "${var.memory_size}"
  timeout          = "${var.timeout}"

  vpc_config {
    subnet_ids         = ["${var.subnet_ids}"]
    security_group_ids = ["${var.sg_ids}"]
  }

  environment {
    variables = "${var.environment}"
  }

  tags = "${var.tags}"
}

data "archive_file" "lambda_zip" {
  type = "zip"

  # add all directory into the zip, including supporting files
  source_dir = "${length(var.source_dir)>0?var.source_dir:path.module}/lambda"

  output_path = "lambda/${var.prefix}-${var.function_name}.zip"
}
