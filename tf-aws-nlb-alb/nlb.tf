resource "aws_eip" "nlb_eip" {
  count = "2"
}

resource "aws_lb" "nlb" {
  name               = "${var.prefix}-${var.role}-nlb"
  load_balancer_type = "network"

  access_logs {
    bucket  = "${var.log_bucket}"
    prefix  = "${var.prefix}-${var.role}-nlb"
    enabled = true
  }

  subnet_mapping {
    allocation_id = "${aws_eip.nlb_eip.0.id}"
    subnet_id     = "${element(var.public_subnet_ids,0)}"
  }

  subnet_mapping {
    allocation_id = "${aws_eip.nlb_eip.1.id}"
    subnet_id     = "${element(var.public_subnet_ids,1)}"
  }

  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "listeners" {
  count = "${var.listeners_count}"

  load_balancer_arn = "${aws_lb.nlb.arn}"
  port              = "${lookup(var.listeners[count.index], "port")}"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${element(aws_lb_target_group.nlb_target_groups.*.arn, count.index)}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "redirects" {
  count = "${var.redirects_count}"

  load_balancer_arn = "${aws_lb.nlb.arn}"
  port              = "${lookup(var.redirects[count.index], "port")}"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${element(aws_lb_target_group.nlb_target_groups_redirects.*.arn, count.index)}"
    type             = "forward"
  }
}

## Create a listen and target group for each of the listeners
resource "aws_lb_target_group" "nlb_target_groups" {
  count = "${var.listeners_count}"

  name = "${var.prefix}-${var.role}-tg-${lookup(var.listeners[count.index], "port")}"

  deregistration_delay = "${var.deregistration_delay}"
  port                 = "${lookup(var.listeners[count.index], "port")}"
  protocol             = "TCP"
  target_type          = "ip"

  vpc_id = "${var.vpc_id}"

  health_check = {
    interval            = "${var.health_check_interval}"
    protocol            = "TCP"
    healthy_threshold   = "${var.healthy_threshold}"
    unhealthy_threshold = "${var.unhealthy_threshold}"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(var.tags,map(
    "prefix"             , "${var.prefix}",
    "role"               , "alb",
    "Name"               , "${var.prefix}-${var.role}-nlb-sg"))}"
}

## Create a listen and target group for each of the listeners
resource "aws_lb_target_group" "nlb_target_groups_redirects" {
  count = "${var.redirects_count}"

  name = "${var.prefix}-${var.role}-tg-${lookup(var.redirects[count.index], "port")}"

  deregistration_delay = "${var.deregistration_delay}"
  port                 = "${lookup(var.redirects[count.index], "port")}"
  protocol             = "TCP"
  target_type          = "ip"

  vpc_id = "${var.vpc_id}"

  health_check = {
    interval            = "${var.health_check_interval}"
    protocol            = "TCP"
    healthy_threshold   = "${var.healthy_threshold}"
    unhealthy_threshold = "${var.unhealthy_threshold}"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(var.tags,map(
    "prefix"             , "${var.prefix}",
    "role"               , "alb",
    "Name"               , "${var.prefix}-${var.role}-nlb-sg"))}"
}

data "dns_a_record_set" "alb_ips" {
  host = "${aws_alb.alb.dns_name}"
}

locals {
  alb_cname_count = "${length(data.dns_a_record_set.alb_ips.addrs)}"
}

resource "aws_lb_target_group_attachment" "nlb_alb" {
  #count            = "${var.listeners_count*local.alb_cname_count}"
  count = "${var.listeners_count*2}" # dependency problem in terraform

  target_group_arn = "${aws_lb_target_group.nlb_target_groups.*.arn[count.index/length(data.dns_a_record_set.alb_ips.addrs)]}"
  target_id        = "${data.dns_a_record_set.alb_ips.addrs[count.index%length(data.dns_a_record_set.alb_ips.addrs)]}"
}

resource "aws_lb_target_group_attachment" "nlb_alb_redirects" {
  #count            = "${var.listeners_count*local.alb_cname_count}"
  count = "${var.redirects_count*2}" # dependency problem in terraform

  target_group_arn = "${aws_lb_target_group.nlb_target_groups_redirects.*.arn[count.index/length(data.dns_a_record_set.alb_ips.addrs)]}"
  target_id        = "${data.dns_a_record_set.alb_ips.addrs[count.index%length(data.dns_a_record_set.alb_ips.addrs)]}"
}
