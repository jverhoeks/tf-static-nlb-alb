resource "aws_alb" "alb" {
  name = "${var.prefix}-${var.role}-alb"

  internal        = true
  security_groups = ["${concat(list(aws_security_group.alb_sg.id),var.extra_sg_ids)}"]

  subnets = ["${var.subnet_ids}"]

  access_logs {
    bucket  = "${var.log_bucket}"
    prefix  = "${var.prefix}-${var.role}-alb"
    enabled = true
  }

  tags = "${merge(var.tags,map(
    "prefix"             , "${var.prefix}",
    "role"               , "alb",
    "Name"               , "staging-alb"
  ))}"
}

resource "aws_alb_listener" "listener" {
  count = "${var.listeners_count}"

  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "${lookup(var.listeners[count.index], "port")}"
  protocol          = "${upper(lookup(var.listeners[count.index], "protocol","http"))}"
  ssl_policy        = "${lookup(var.listeners[count.index], "protocol")=="https"?lookup(var.listeners[count.index], "ssl_policy",var.ssl_policy):""}"
  certificate_arn   = "${lookup(var.listeners[count.index], "protocol")=="https"?var.certificate_arn:""}"

  default_action {
    target_group_arn = "${lookup(var.listeners[count.index], "default_target")}"
    type             = "forward"
  }
}

# add extra certicicate to listeners
resource "aws_lb_listener_certificate" "listener" {
  listener_arn    = "${aws_alb_listener.listener.*.arn[lookup(var.extra_ssl_certs_listeners[count.index], "https_listener_index")]}"
  certificate_arn = "${lookup(var.extra_ssl_certs_listeners[count.index], "certificate_arn")}"
  count           = "${length(var.extra_ssl_certs_listeners)}"
}

resource "aws_alb_listener" "redirect" {
  count = "${var.redirects_count}"

  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "${lookup(var.redirects[count.index],"port")}"
  protocol          = "${upper(lookup(var.redirects[count.index], "protocol","http"))}"
  ssl_policy        = "${lookup(var.redirects[count.index], "protocol")=="https"?lookup(var.redirects[count.index], "ssl_policy",var.ssl_policy):""}"
  certificate_arn   = "${lookup(var.redirects[count.index], "protocol")=="https"?var.certificate_arn:""}"

  default_action {
    type = "redirect"

    redirect {
      port        = "${lookup(var.redirects[count.index],"target_port","443")}"
      protocol    = "${upper(lookup(var.redirects[count.index],"target_protocol","HTTPS"))}"
      status_code = "${lookup(var.redirects[count.index],"target_code","HTTP_301")}"
    }
  }
}

# add extra certicicate to listeners
resource "aws_lb_listener_certificate" "redirect" {
  listener_arn    = "${aws_alb_listener.redirect.*.arn[lookup(var.extra_ssl_certs_redirects[count.index], "https_redirect_index")]}"
  certificate_arn = "${lookup(var.extra_ssl_certs_redirects[count.index], "certificate_arn")}"
  count           = "${length(var.extra_ssl_certs_redirects)}"
}

# Security Group for the ELBv2
resource "aws_security_group" "alb_sg" {
  name        = "${var.prefix}-${var.role}-alb-sg"
  vpc_id      = "${var.vpc_id}"
  description = "staging ALB SG"

  tags = "${merge(var.tags,map(
    "prefix"             , "${var.prefix}",
    "role"               , "alb",
    "Name"               , "${var.prefix}-${var.role}-alb-sg"
  ))}"
}

# Outbound Rules
resource "aws_security_group_rule" "alb_sg_outbound_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb_sg.id}"
}

# resource "aws_security_group_rule" "alb_http_listener" {
#   count                    = "${var.listeners_count}"
#   type                     = "ingress"
#   from_port                = "${lookup(var.listeners[count.index], "port")}"
#   to_port                  = "${lookup(var.listeners[count.index], "port")}"
#   protocol                 = "tcp"
#   source_security_group_id = "${aws_security_group.nlb_sg.id}"
#   security_group_id        = "${aws_security_group.alb_sg.id}"
# }

# Ephemeral Ports
# Docker version 1.6.0 and later, the Docker daemon tries to read the ephemeral
# port range from /proc/sys/net/ipv4/ip_local_port_range (which is 32768 to
# 61000 on the latest Amazon ECS-optimized AMI)
resource "aws_security_group_rule" "alb_ecs_cluster_ephemeral_ports" {
  count                    = "${length(var.target_sg_ids)}"
  type                     = "ingress"
  from_port                = "32768"
  to_port                  = "61000"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.alb_sg.id}"
  security_group_id        = "${var.target_sg_ids[count.index]}"
  description              = "Docker daemon tries these ports ${count.index}"
}

resource "aws_security_group_rule" "alb_ecs_port" {
  count                    = "${length(var.target_sg_ids)}"
  type                     = "ingress"
  from_port                = "${lookup(var.listeners[0], "target_port")}"
  to_port                  = "${lookup(var.listeners[0], "target_port")}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.alb_sg.id}"
  security_group_id        = "${var.target_sg_ids[count.index]}"
  description              = "Docker daemon tries these ports ${count.index}  "
}

resource "aws_security_group_rule" "alb_ecs_port_redirects" {
  count                    = "${length(var.target_sg_ids)}"
  type                     = "ingress"
  from_port                = "${lookup(var.redirects[0], "target_port")}"
  to_port                  = "${lookup(var.redirects[0], "target_port")}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.alb_sg.id}"
  security_group_id        = "${var.target_sg_ids[count.index]}"
  description              = "Docker daemon tries these ports ${count.index}  "
}
