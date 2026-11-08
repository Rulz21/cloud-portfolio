# ---------- 1. The notebook: DynamoDB table ----------
# 1 read + 1 write unit is enough for a portfolio, and stays inside DynamoDB's always-free allowance.
resource "aws_dynamodb_table" "visitors" {
  name           = "visitor-counter"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# ---------- 2. The worker's permissions (IAM role) ----------
# WHO can wear this role: the Lambda service
data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "counter_lambda" {
  name               = "visitor-counter-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

# WHAT it can do: update this one table. Nothing else.
data "aws_iam_policy_document" "counter_table_access" {
  statement {
    actions   = ["dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.visitors.arn]
  }
}

resource "aws_iam_role_policy" "counter_table_access" {
  name   = "update-visitor-table"
  role   = aws_iam_role.counter_lambda.id
  policy = data.aws_iam_policy_document.counter_table_access.json
}

# Also allow it to write logs (AWS-provided policy)
resource "aws_iam_role_policy_attachment" "counter_logs" {
  role       = aws_iam_role.counter_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Keep logs for 14 days only, so they don't pile up forever
resource "aws_cloudwatch_log_group" "counter" {
  name              = "/aws/lambda/visitor-counter"
  retention_in_days = 14
}

# ---------- 3. The worker: Lambda function ----------
data "archive_file" "counter" {
  type        = "zip"
  source_file = "${path.module}/../backend/counter/app.py"
  output_path = "${path.module}/build/counter.zip"
}

resource "aws_lambda_function" "counter" {
  function_name    = "visitor-counter"
  role             = aws_iam_role.counter_lambda.arn
  runtime          = "python3.13"
  handler          = "app.lambda_handler"
  filename         = data.archive_file.counter.output_path
  source_code_hash = data.archive_file.counter.output_base64sha256
  timeout          = 5
  memory_size      = 128

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitors.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.counter]
}

# ---------- 4. The front desk bell: API Gateway ----------
resource "aws_apigatewayv2_api" "counter" {
  name          = "visitor-counter-api"
  protocol_type = "HTTP"

  # Only my website is allowed to call this API from a browser
  cors_configuration {
    allow_origins = ["https://${aws_cloudfront_distribution.site.domain_name}"]
    allow_methods = ["POST"]
  }
}

resource "aws_apigatewayv2_integration" "counter" {
  api_id                 = aws_apigatewayv2_api.counter.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.counter.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "visit" {
  api_id    = aws_apigatewayv2_api.counter.id
  route_key = "POST /visit"
  target    = "integrations/${aws_apigatewayv2_integration.counter.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.counter.id
  name        = "$default"
  auto_deploy = true

  # Speed limit: protects you from someone spamming the API and running up costs
  default_route_settings {
    throttling_burst_limit = 20
    throttling_rate_limit  = 10
  }
}

# Let API Gateway ring the worker's bell
resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.counter.execution_arn}/*/*"
}