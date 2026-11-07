terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  # Labels added to everything Terraform creates
  default_tags {
    tags = {
      Project   = "cloud-portfolio"
      ManagedBy = "terraform"
    }
  }
}