#datadog
resource "aws_ssm_parameter" "datadog_api_key" {
  name   = var.datadog_api_key_ssm_param_name
  type   = "String"
  value  = var.datadog_api_key
  key_id = aws_kms_key.datadog_api.id
}
resource "aws_kms_key" "datadog_api" {
  description         = "KMS key for Polygon Edge Datadog API Key"
  enable_key_rotation = true
}

resource "aws_iam_role_policy" "datadog" {
  role   = data.aws_iam_instance_profile.validators.role_name
  policy = data.aws_iam_policy_document.datadog.json
}

data "aws_iam_policy_document" "datadog" {
  statement {
    actions = [
      "kms:Decryt"
    ]
    resources = [
      aws_kms_key.datadog_api.arn
    ]
  }
  statement {
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      aws_ssm_parameter.datadog_api_key.arn
    ]
  }
}
