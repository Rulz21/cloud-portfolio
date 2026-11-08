# A dedicated "robot" user for GitHub Actions.
# OIDC providers are blocked by an SCP in this account type,
# so we use an access key with the smallest possible permissions.
resource "aws_iam_user" "github_deploy" {
  name = "github-actions-deploy-site"
}

# WHAT the robot may do: upload to my bucket + clear my CloudFront cache. Nothing else.
data "aws_iam_policy_document" "deploy_permissions" {
  statement {
    sid       = "ListSiteBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.site.arn]
  }

  statement {
    sid       = "ManageSiteFiles"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]
  }

  statement {
    sid       = "ClearCache"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [aws_cloudfront_distribution.site.arn]
  }
}

resource "aws_iam_user_policy" "github_deploy" {
  name   = "deploy-site"
  user   = aws_iam_user.github_deploy.name
  policy = data.aws_iam_policy_document.deploy_permissions.json
}