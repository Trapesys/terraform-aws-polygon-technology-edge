output "datadog_api_key_ssm_param_name" {
  description = "The SSM Parameter name"
  value       = aws_ssm_parameter.datadog_api_key.name
}
