data "archive_file" "app_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

data "archive_file" "rotate_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/rotation_lambda"
  output_path = "${path.module}/rotation_lambda.zip"
}

resource "aws_lambda_function" "secure_lambda" {
  function_name = "${var.project_name}-function"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.app_lambda_zip.output_path

  environment {
    variables = {
      SECRET_NAME = var.secret_name
    }
  }

  depends_on = [data.archive_file.app_lambda_zip]
}

resource "aws_lambda_function" "rotation_function" {
  function_name = "${var.project_name}-rotation"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "rotation.lambda_handler"  # <-- FIXED
  runtime       = "python3.11"
  filename      = data.archive_file.rotate_lambda_zip.output_path

  environment {
    variables = {
      SECRET_NAME = var.secret_name
    }
  }

  depends_on = [data.archive_file.rotate_lambda_zip]
}

resource "aws_lambda_permission" "allow_secrets_manager" {
  statement_id  = "AllowSecretsManagerInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotation_function.function_name
  principal     = "secretsmanager.amazonaws.com"
}
