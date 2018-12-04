output "role_id" {
  value = "${module.lambda_populate_nlb_alb.role_id}"
}

output "role_arn" {
  value = "${module.lambda_populate_nlb_alb.role_arn}"
}

output "role_unique_id" {
  value = "${module.lambda_populate_nlb_alb.role_unique_id}"
}

#
# output "nlb_sg_id" {
#   value = "${aws_security_group.nlb_sg.id}"
# }

output "listeners" {
  value = "${aws_alb_listener.listener.*.id}"
}

output "alb_sg_id" {
  value = "${aws_security_group.alb_sg.id}"
}

output "load_balancer_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = "${aws_lb.nlb.zone_id}"
}

output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = "${aws_lb.nlb.dns_name}"
}
