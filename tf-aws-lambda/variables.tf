variable "prefix" {
  description = "Stack/Prefix for resources"
}

variable "region" {
  description = "AWS Region"
}

variable "function_name" {
  description = "Lambda functionname"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = "map"
}

variable "sg_ids" {
  description = "List of security groups"
  default     = []
}

variable "subnet_ids" {
  description = "List of subnets groups"
  default     = []
}

variable "alarm_topic" {
  description = "Topic for alarms"
  default     = ""
}

variable "aws_account_id" {
  description = "AWS Account ID"
}

variable "description" {
  default = "Lambda"
}

variable "runtime" {
  default = "nodejs8.10"
}

variable "handler" {
  default = "index.handler"
}

variable "memory_size" {
  default = "128"
}

variable "timeout" {
  default = "300"
}

variable "resource_arn" {
  description = "Source Resource for Lambda Permissions"
  default     = ""
}

variable "environment" {
  description = "Environment setttings"
  type        = "map"

  default = {
    "test" = "test"
  }
}

variable "source_dir" {
  description = "Source directory for /lambda directory. Don't include the /lambda"
  default     = ""
}

/**
 * A cron or rate expression.
 * See: http://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
 */
variable "schedule_expression" {
  description = "A cron or rate expression"
  default     = ""
}
