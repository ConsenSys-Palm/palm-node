data "aws_acm_certificate" "eth_cert" {
  domain = "*.eth.niftys.com"
}

data "aws_vpc" "vpc" {
  id = var.vpc_details["vpc_id"]
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Name = "public"
  }
}

data "aws_route53_zone" "zone" {
  name = "niftys.com."
}