output "dns_name" {
  value       = aws_lb.polygon_nodes.dns_name
  description = "The dns name for the JSON-RPC"
}

output "zone_id" {
  value       = aws_lb.polygon_nodes.zone_id
  description = "The zone id for the JSON-RPC LB"
}

output "alb_target_group_arn" {
  value       = aws_lb_target_group.polygon_nodes.arn
  description = "The dns name for the JSON-RPC"
}
