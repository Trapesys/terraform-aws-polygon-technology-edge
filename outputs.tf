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
