/*
data "null_data_source" "downloaded_package" {
  inputs = {
    id       = null_resource.download_package.id
    filename = local.downloaded
  }
}
*/

data "aws_availability_zones" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
