resource "aws_sfn_state_machine" "main" {
  name     = var.state_machine_name
  role_arn = aws_iam_role.iam_for_sfn.arn
  definition = jsonencode(templatefile("${path.module}/templates/definition.json"), {

  })
}

module "lambda_prepare" {
  source  = "terraform-aws-modules/lambda/aws"
  version = ">=3.3.1"

  function_name = var.lambda_function_identifier_prefix
  description   = "Lambda function used to prepare and check for existing secrets"

  timeout     = 20
  memory_size = 256

  # docker Configuration
  docker_image = var.polygon_edge_iamge

  attach_policy_jsons = true
}

module "lambda_genesis" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "4.0.1"

  function_name = var.lambda_function_identifier_prefix
  description   = "Lambda function used to generate and store chain in S3"

  timeout     = 20
  memory_size = 256

  create_package = false

  # docker Configuration
  image_uri = var.polygon_edge_iamge
  image_config_command = ["-c", templatefile("${path.modules}/templates/genesis.sh", {

    })
  ]
  image_config_entry_point       = ["sh"]
  image_config_working_directory = "/polygon-edge/data"

  environment_variables = {
    SECRETS_MANAGER_CONFIG_TEMPLATE = jsonencode(local.secrets_manager_config_template)
    VALIDATOR_COUNT                 = var.validator_count
    SECRETS_MANAGER_CONFIG_BUCKET   = aws_s3_bucket.store.id
  }

  attach_policy_jsons = true
}
