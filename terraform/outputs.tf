output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.application-load-balancer.dns_name
}

output "bastion_dns_name" {
  description = "DNS name of the bastion machine"
  value       = aws_instance.bastion.public_dns
}

output "cdn_url" {
  value = aws_cloudfront_distribution.cf_dist.domain_name
}
