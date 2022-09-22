output "jsonrpc_dns_name" {
  value       = module.alb.dns_name
  description = "The dns name for the JSON-RPC API"
}

output "alb" {
  value = {
    zone_id  = module.alb.zone_id
    dns_name = module.alb.dns_name
  }
  description = "The dns name for the JSON-RPC API"
}
output "private_subnets" {
  value       = local.private_subnets
  description = "The private subnets"
}
output "public_subnets" {
  value       = local.public_subnets
  description = "The public subnets"
}
output "vpc_id" {
  value       = module.vpc.vpc_attributes.id
  description = "The VPC ID"
}
output "rpc_security_group_id" {
  value       = module.security.jsonrpc_sec_group_id
  description = "The RPC security group id"
}

