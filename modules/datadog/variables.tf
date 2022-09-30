variable "instance_iam_role" {
  type        = string
  description = "The IAM role to attach to the instance"
}

variable "datadog_api_key_ssm_param_name" {
  description = "The Datadog API key ssm parameter name"
  type        = string
  default     = "dd-api-key-for-ssm"
}

variable "datadog_api_key" {
  description = "The Datadog API key"
  sensitive   = true
  type        = string
  default     = ""
}
