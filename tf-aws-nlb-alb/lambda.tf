module "lambda_populate_nlb_alb" {
  source = "../../local_modules/tf-aws-lambda"

  prefix         = "${var.prefix}"
  tags           = "${var.tags}"
  region         = "${var.region}"
  aws_account_id = "${var.aws_account_id}"
  function_name  = "populate_NLB_TG_with_ALB"

  # override the directory for the lambda source code. Script will zip all in the subdirectory lambda
  source_dir = "${path.module}"
  runtime    = "python3.6"
  handler    = "lambda.handler"

  sg_ids              = ["${aws_security_group.alb_sg.id}"]
  subnet_ids          = "${var.subnet_ids}"
  schedule_expression = "${var.schedule_expression}"

  environment = "${map("ALB_DNS_NAME","${aws_alb.alb.dns_name}",
                         "ALB_LISTENER","80,443",
                         "S3_BUCKET","${aws_s3_bucket.nlb_alb_s3.id}",
                         "NLB_TG_ARN","${aws_lb_target_group.nlb_target_groups.0.arn}",
                         "MAX_LOOKUP_PER_INVOCATION","50",
                         "INVOCATIONS_BEFORE_DEREGISTRATION","3",
                         "CW_METRIC_FLAG_IP_COUNT","true"
                         )}"

  alarm_topic = "${var.alarm_topic}"
}

// Access from pritunl server
// EC2 Servers needs also describesecret
resource "aws_iam_role_policy" "lambda_populate_nlb_alb_policy" {
  name = "lambda_populate_nlb_alb_policy"
  role = "${module.lambda_populate_nlb_alb.role_id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ],
      "Effect": "Allow",
      "Sid": "LambdaLogging"
    },
    {
      "Action": [
        "s3:Get*",
        "s3:PutObject",
        "s3:CreateBucket",
        "s3:ListBucket",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "S3"
    },
    {
      "Action": [
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "ELB"
    },
    {
      "Action": [
        "cloudwatch:putMetricData"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "CW"
    }
  ]
}
EOF
}
