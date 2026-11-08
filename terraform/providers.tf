terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }

  backend "s3" {
    bucket       = "hairul-tfstate"
    key          = "cloud-portfolio/terraform.tfstate"
    region       = "ap-southeast-2"
    profile      = "portfolio"
    encrypt      = true
    use_lockfile = true
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