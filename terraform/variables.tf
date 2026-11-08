variable "region" {
  description = "AWS region for the S3 bucket"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile used to log in"
  type        = string
  default     = "portfolio"
}
