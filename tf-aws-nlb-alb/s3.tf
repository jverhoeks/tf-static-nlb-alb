resource "aws_s3_bucket" "nlb_alb_s3" {
  bucket = "${var.prefix}-${var.role}-alb-lambda"
  acl    = "private"

  # GDPR Requirements
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${merge(var.tags,map(
    "prefix"             , "${var.prefix}",
    "Name"               , "${var.prefix}-${var.role}-alb-lambda",
    "GDPR"               , "None"))}"
}
