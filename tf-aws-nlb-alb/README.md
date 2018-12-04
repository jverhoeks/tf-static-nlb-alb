# Static IP for ALB

Based on: https://aws.amazon.com/blogs/networking-and-content-delivery/using-static-ip-addresses-for-application-load-balancers/


## Diagram
```

      NLB                                    ALB  Internal VPC        
      +-----------------------+             +------------------------------+
      |                       |             |                              |
      |  +--------+  +------+ |             | +--------+    +------------+ |
      |  |LIST 80 |  |TG_80 --------------SG---LIST 80 |    |App 1: Rule | |
 +----+  +--------+  +------+ |             | +--------+    |App 1: TG   | |
+|2EIP|                       |             |               +------------+ |
 +----+  +--------+  +------+ |             | +--------+    +------------+ |
      |  |LIST 443|  |TG_443|-|-----------SG|-|LIST 443|    |App 2: Rule | |
      |  +--------+  +------+ |             | +--------+    |App 2: TG   | |
      |                       |             |               +------------+ |
      |                       |             |                              |
      +-----------------------+             +------------------------------+

                                 +---------------+                              
          NLB Acts as a          | LAMBDA        |                              
          transperant proxy      | Update NLB TG |                              
          with Elastic IP        | With ALB IP   |                              
          for the ALB            | from cname    |                              
                                 +---------------+          
```                    

## Security Groups

The NLB doesn't have security groups. Only the alb. For the healthcheck of the NLB:
* If the ALB is internal it uses IP from the vpc subnet assigned to the public zone
* If the ALB is external it uses the Elasticip

## Inputs


| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alarm_topic | Topic for alarms | string | `` | no |
| aws_account_id | AWS Account ID | string | - | yes |
| certificate_arn | ARN for outside certificate | string | `` | no |
| default_target_group | Default target group for alb | string | - | yes |
| deregistration_delay | The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused | string | `15` | no |
| extra_sg_ids | Extra SG to be attached to alb | list | `<list>` | no |
| health_check_interval | The interval between performing a health check | string | `30` | no |
| healthy_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy | string | `3` | no |
| idle_timeout | The timeout applie to idle ELB connections | string | `60` | no |
| listeners | An array of listeners to setup for the NLB | list | - | yes |
| log_bucket | Logbucket for Loadbalancers | string | `` | no |
| prefix | Stack/Prefix for resources | string | - | yes |
| public_subnet_ids | List of subnets groups | string | `<list>` | no |
| region | AWS Region | string | - | yes |
| role | Role name for resources | string | - | yes |
| schedule_expression | A cron or rate expression | string | `` | no |
| sg_ids | List of security groups | string | `<list>` | no |
| ssl_policy | Default ssl policy | string | `ELBSecurityPolicy-2016-08` | no |
| subnet_ids | List of subnets groups | string | `<list>` | no |
| tags | A mapping of tags to assign to the resource | map | - | yes |
| target_sg_ids | Target Security Groups | string | `<list>` | no |
| unhealthy_threshold | The number of consecutive health check failures required before considering the target unhealthy | string | `3` | no |
| vpc_id | VPC Id | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| alb_sg_id |  |
| dns_name | The DNS name of the load balancer. |
| listeners |  |
| load_balancer_zone_id | The zone_id of the load balancer to assist with creating DNS records. |
| role_arn |  |
| role_id |  |
| role_unique_id |  |


# Example

Requires an application module that specifies it's own target_group and role.
Via module.stg_nlb_static.listeners it's possible to pass the listeners to the application.


```terraform
module "stg_nlb_static" {
  source         = "../../local_modules/tf-aws-nlb-alb"
  prefix         = "${var.prefix["staging"]}"
  role           = "test"
  tags           = {}
  region         = "${var.env["region"]}"
  aws_account_id = "${var.aws_account_id}"

  vpc_id              = "${module.staging_vpc.vpc_id}"
  subnet_ids          = "${module.staging_vpc.private_subnet_ids}"
  public_subnet_ids   = ["${module.staging_vpc.public_subnet_ids}"]
  certificate_arn     = "${aws_acm_certificate.staging_cert.arn}"

  schedule_expression = "cron(0 0 * * ? *))"
  alarm_topic         = "${aws_sns_topic.staging_cloudwatch_notifications.arn}"

  log_bucket = "${aws_s3_bucket.stg_nextcloud_logs_alb.id}"

  default_target_group = "${module.application.alb_target}"
  target_sg_ids       = ["${module.staging_ecs_cluster.ec2_sg_id}"]
  certificate_arn      = "${aws_acm_certificate.staging_cert.arn}"

  listeners = [
    {
      port           = "80"
      protocol       = "http"
      default_target = "${module.application.alb_target}"
      target_port    = "80"
    },
    {
      port           = "443"
      protocol       = "https"
      default_target = "${module.stg-application.alb_target}"
      target_port    = "80"
    },
  ]
}


resource "aws_security_group_rule" "alb_http_listener_https" {
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["${var.office_ips}", "${var.staging_vpc["cidr_block"]}"]
  security_group_id = "${module.stg_nlb_static.alb_sg_id}"
}
```
