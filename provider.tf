terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region              = "ap-southeast-1"
  shared_config_files = ["/Users/sonnguyen/.aws/config"]
  profile             = "credentials"
}
