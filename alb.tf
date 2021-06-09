// Target Groups
resource "aws_lb_target_group" "mainnet_http" {
  name     = "palm-mainnet-http"
  port     = 8545
  protocol = "HTTP"
  vpc_id   = var.vpc_details["vpc_id"]

  health_check {
    unhealthy_threshold = 2
    healthy_threshold   = 5
    interval            = 60
    timeout             = 30
    path                = "/liveness"
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "testnet_http" {
  name     = "palm-testnet-http"
  port     = 8545
  protocol = "HTTP"
  vpc_id   = var.vpc_details["vpc_id"]

  health_check {
    unhealthy_threshold = 2
    healthy_threshold   = 5
    interval            = 60
    timeout             = 30
    path                = "/liveness"
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "mainnet_ws" {
  name     = "palm-mainnet-ws"
  port     = 8546
  protocol = "HTTP"
  vpc_id   = var.vpc_details["vpc_id"]

  health_check {
    unhealthy_threshold = 2
    healthy_threshold   = 5
    interval            = 60
    timeout             = 30
    path                = "/liveness"
    port                = 8545
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "testnet_ws" {
  name     = "palm-testnet-ws"
  port     = 8546
  protocol = "HTTP"
  vpc_id   = var.vpc_details["vpc_id"]

  health_check {
    unhealthy_threshold = 2
    healthy_threshold   = 5
    interval            = 60
    timeout             = 30
    path                = "/"
    port                = 8545
    matcher             = "405"
  }
}

// Target group attachments
resource "aws_lb_target_group_attachment" "mainnet_http" {
  target_group_arn = aws_lb_target_group.mainnet_http.arn
  target_id        = module.palmnode_mainnet.besu_nodes[0].id
  port             = 8545
}

resource "aws_lb_target_group_attachment" "testnet_http" {
  target_group_arn = aws_lb_target_group.testnet_http.arn
  target_id        = module.palmnode_uat.besu_nodes[0].id
  port             = 8545
}

resource "aws_lb_target_group_attachment" "mainnet_ws" {
  target_group_arn = aws_lb_target_group.mainnet_ws.arn
  target_id        = module.palmnode_mainnet.besu_nodes[0].id
  port             = 8546
}

resource "aws_lb_target_group_attachment" "testnet_ws" {
  target_group_arn = aws_lb_target_group.testnet_ws.arn
  target_id        = module.palmnode_uat.besu_nodes[0].id
  port             = 8546
}

// Load balancer Listeners
resource "aws_alb_listener" "mainnet_http" {
  depends_on        = [aws_lb.mainnet_http]
  load_balancer_arn = aws_lb.mainnet_http.arn
  port              = "8545"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.eth_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mainnet_http.arn
  }
}

resource "aws_alb_listener" "mainnet_ws" {
  depends_on        = [aws_lb.mainnet_http]
  load_balancer_arn = aws_lb.mainnet_http.arn
  port              = "8546"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.eth_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mainnet_ws.arn
  }
}

resource "aws_alb_listener" "testnet_http" {
  depends_on        = [aws_lb.testnet_http]
  load_balancer_arn = aws_lb.testnet_http.arn
  port              = "8545"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.eth_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.testnet_http.arn
  }
}

resource "aws_alb_listener" "testnet_ws" {
  depends_on        = [aws_lb.testnet_http]
  load_balancer_arn = aws_lb.testnet_http.arn
  port              = "8546"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.eth_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.testnet_ws.arn
  }
}

// Load balancers
resource "aws_lb" "mainnet_http" {
  name               = "palm-mainnet"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.palmnode_mainnet.besu_rpc_sg.id]
  subnets            = data.aws_subnet_ids.public.ids

  tags = {
    Name      = "Palm mainnet HTTP"
    ManagedBy = "Terraform"
  }
}

resource "aws_lb" "testnet_http" {
  name               = "palm-testnet-http"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.palmnode_uat.besu_rpc_sg.id]
  subnets            = data.aws_subnet_ids.public.ids

  tags = {
    Name      = "Palm testnet HTTP"
    ManagedBy = "Terraform"
  }
}

// Route53 routes
resource "aws_route53_record" "mainnet_http" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "palm.eth.niftys.com"
  type    = "A"

  alias {
    name                   = aws_lb.mainnet_http.dns_name
    zone_id                = aws_lb.mainnet_http.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "testnet_http" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "palm-testnet.eth.niftys.com"
  type    = "A"

  alias {
    name                   = aws_lb.testnet_http.dns_name
    zone_id                = aws_lb.testnet_http.zone_id
    evaluate_target_health = true
  }
}
