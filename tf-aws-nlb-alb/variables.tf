variable "prefix" {
  description = "Stack/Prefix for resources"
}

variable "role" {
  description = "Role name for resources"
}

variable "region" {
  description = "AWS Region"
}

variable "ssl_policy" {
  description = "Default ssl policy"
  default     = "ELBSecurityPolicy-2016-08"
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

variable "public_subnet_ids" {
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

variable "certificate_arn" {
  description = "ARN for outside certificate"
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

variable "target_sg_ids" {
  description = "Target Security Groups"
  default     = []
}

variable "extra_sg_ids" {
  description = "Extra SG to be attached to alb"
  default     = []
  type        = "list"
}

variable "vpc_id" {
  description = "VPC Id"
}

variable "default_target_group" {
  description = "Default target group for alb"
}

variable "listeners_count" {
  description = "Count of an array of listeners to setup for the NLB"
  type        = ""
}

variable "listeners" {
  description = "An array of listeners to setup for the NLB"
  type        = "list"
}

variable "redirects_count" {
  description = "Count of an array of redirectss to setup for the NLB"
  type        = ""
}

variable "redirects" {
  description = "An array of redirects to setup for the NLB"
  type        = "list"
}

variable "idle_timeout" {
  description = "The timeout applie to idle ELB connections"
  default     = "60"
}

variable "deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused"
  default     = "15"
}

variable "health_check_interval" {
  description = "The interval between performing a health check"
  default     = "30"
}

variable "healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
  default     = "3"
}

variable "unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy"
  default     = "3"
}

variable "log_bucket" {
  description = "Logbucket for Loadbalancers"
  default     = ""
}

variable "extra_ssl_certs_listeners" {
  description = "Extra ssl certificate for listeners"
  default     = []
  type        = "list"
}

variable "extra_ssl_certs_redirects" {
  description = "Extra ssl certificate for redirects"
  default     = []
  type        = "list"
}
