/* Permissions for the lambda function_arn
 *
 * Access to the S3 bucket
 * Access to Elasticsearch
 *
 * Logging to cloudwatch
 */

resource "aws_iam_role" "iam_for_lambda" {
  name_prefix = "lambda_iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "run_lambda_policy" {
  role        = "${aws_iam_role.iam_for_lambda.id}"
  name_prefix = "${var.prefix}-lambdapol"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "VisualEditor1",
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogStream",
              "logs:DescribeLogStreams",
              "logs:PutLogEvents"
          ],
          "Resource": [
              "arn:aws:logs:*:${var.aws_account_id}:log-group:*"
          ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "logs:PutLogEvents",
            "Resource": "arn:aws:logs:*:${var.aws_account_id}:log-group:*:*:*"
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DetachNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor4",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        }
    ]
}
EOF
}
