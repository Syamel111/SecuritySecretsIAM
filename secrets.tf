resource "aws_secretsmanager_secret" "app_secret" {
  name = var.secret_name
}

resource "aws_secretsmanager_secret_version" "app_secret_value" {
  secret_id     = aws_secretsmanager_secret.app_secret.id
  secret_string = jsonencode({ api_key = "example-1234-key" })
}

resource "aws_secretsmanager_secret_rotation" "rotation" {
  secret_id           = aws_secretsmanager_secret.app_secret.id
  rotation_lambda_arn = aws_lambda_function.rotation_function.arn
  rotation_rules {
    automatically_after_days = 7
  }
}
