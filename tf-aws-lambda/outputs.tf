output "role_id" {
  value = "${aws_iam_role.iam_for_lambda.id}"
}

output "role_arn" {
  value = "${aws_iam_role.iam_for_lambda.arn}"
}

output "role_unique_id" {
  value = "${aws_iam_role.iam_for_lambda.unique_id}"
}

output "lambda_arn" {
  value = "${aws_lambda_function.func.arn}"
}

output "lambda_qualified_arn" {
  value = "${aws_lambda_function.func.qualified_arn}"
}

output "lambda_invoke_arn" {
  value = "${aws_lambda_function.func.invoke_arn}"
}
