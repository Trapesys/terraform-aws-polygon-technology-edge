variable "instance_monitoring_enabled" {
  type        = string
  description = "Enable instance monitoring"
  default     = false
}
variable "instance_type" {
  type        = string
  description = "Polygon Edge nodes instance type. Default: t3.medium"
}
variable "az" {
  type        = string
  description = "The availability zone of the instance."
}

variable "internal_subnet" {
  description = "The subnet id in which to place the instance."
  type        = string
}

variable "internal_sec_groups" {
  type        = list(string)
  description = "The list of security groups to attach to the instance."
}

variable "instance_interface_name_tag" {
  type        = string
  description = "The name of the instance interface. Default: Polygon_Edge_Instance_Interface"
}

variable "chain_data_ebs_volume_size" {
  type        = number
  description = "The size of the chain data EBS volume. Default: 30"
}

variable "chain_data_ebs_name_tag" {
  type        = string
  description = "The name of the chain data EBS volume. Default: Polygon_Edge_chain_data_ebs_volume"
}

variable "instance_iam_role" {
  type        = string
  description = "The IAM role to attach to the instance"
}

variable "alb_target_group_arn" {
  type        = string
  description = "The ALB target group arn"
}
variable "propagated_asg_tags" {
  type        = map(string)
  description = "A map of tags to propagate to the validator nodes"
  default     = {}
}

# server options
variable "prometheus_address" {
  type        = string
  description = "Enable Prometheus API"
}
variable "block_gas_target" {
  type        = string
  description = "Sets the target block gas limit for the chain"
}
variable "nat_address" {
  type        = string
  description = "Sets the NAT address for the networking package"
}
variable "dns_name" {
  type        = string
  description = "Sets the DNS name for the network package"
}
variable "price_limit" {
  type        = string
  description = "Sets minimum gas price limit to enforce for acceptance into the pool"
}
variable "max_slots" {
  type        = string
  description = "Sets maximum slots in the pool"
}
variable "block_time" {
  type        = string
  description = "Set block production time in seconds"
}
variable "polygon_edge_dir" {
  type        = string
  description = "The directory to place all polygon-edge data and logs"
}
variable "ebs_device" {
  type        = string
  description = "The ebs device path. Defined when creating EBS volume."
}
variable "assm_path" {
  type        = string
  description = "The SSM paramter path."
}
variable "node_name" {
  type        = string
  description = "The name of the node that will be different for every node and stored in AWS SSM"
}
variable "total_nodes" {
  type        = string
  description = "The total number of validator nodes."
}
variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket that holds genesis.json."
}
## genesis options
variable "genesis_path" {
  type        = string
  description = "The path to genesis"
  default     = ""
}
variable "enable_validators" {
  type        = bool
  description = "Toggles the Validator ASG to 1 or 0"
  default     = true
}

variable "datadog_api_key_ssm_param_name" {
  description = "The Datadog API key ssm parameter name"
  type        = string
  default     = "dd-api-key-for-ssm"
}
variable "datadog_environment_tag" {
  description = "The Datadog environment tag"
  type        = string
  default     = "devnet"
}
