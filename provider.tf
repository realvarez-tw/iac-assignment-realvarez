terraform {
  required_version = "~> 1.8.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }

}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = var.prefix
      Environment = "Demo"
    }
  }
}