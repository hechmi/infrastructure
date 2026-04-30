variable "function_name" { type = string }
variable "runtime" { type = string; default = "python3.12" }
variable "handler" { type = string; default = "handler.handler" }
variable "memory_size" { type = number; default = 256 }
variable "timeout" { type = number; default = 30 }
variable "environment" { type = string }
variable "tags" { type = map(string); default = {} }

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  runtime       = var.runtime
  handler       = var.handler
  memory_size   = var.memory_size
  timeout       = var.timeout
  role          = aws_iam_role.lambda.arn
  tags          = merge(var.tags, { Environment = var.environment })

  filename         = "placeholder.zip"
  source_code_hash = "placeholder"
}

resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.tags
}

output "function_name" { value = aws_lambda_function.this.function_name }
output "function_arn" { value = aws_lambda_function.this.arn }
output "role_arn" { value = aws_iam_role.lambda.arn }
