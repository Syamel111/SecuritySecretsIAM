# 🔐 Lesson 4 – Secrets Manager Rotation & IAM Security (Mini Project 3)

This project demonstrates how to build a production-grade secrets rotation setup using AWS Secrets Manager, Lambda, and Terraform.

---

## 📌 Features

- ✅ Custom Secrets Rotation Lambda (`rotation.py`)
- ✅ IAM Role & Least Privilege for Rotation
- ✅ Terraform-managed deployment
- ✅ Manual CLI rotation trigger and error inspection
- ✅ Real-world error handling and recovery

---

## 📁 Project Structure

lesson-4-secrets-security/
├── main.tf
├── lambda.tf
├── iam.tf
├── secret.tf
├── outputs.tf
├── rotation_lambda/
│ ├── rotation.py


---

## 🚀 How to Deploy

1. **Zip the Lambda function**:
   ```bash
   cd rotation_lambda
   zip ../rotation.zip rotation.py
   cd ..

run terraform
terraform init
terraform apply

Attach rotation to secret (if needed):
aws secretsmanager cancel-rotate-secret --secret-id lesson4-api-key
aws secretsmanager rotate-secret \
  --secret-id lesson4-api-key \
  --rotation-lambda-arn arn:aws:lambda:ap-southeast-1:XXXXXXXXXXXX:function:lesson4-secrets-rotation \
  --rotation-rules AutomaticallyAfterDays=7

manually rotate secret
aws secretsmanager rotate-secret --secret-id lesson4-api-key

🛠 Common Issues & Fixes
| Problem                      | Solution                                                                               |
| ---------------------------- | -------------------------------------------------------------------------------------- |
| `No module named 'rotation'` | Ensure zip contains `rotation.py`, not a folder. Handler should be `rotation.handler`. |
| Log stream not found         | Check if Lambda has permission to create log groups.                                   |
| Rotation stuck               | Use `cancel-rotate-secret` before re-rotating.                                         |
| IAM Access Denied            | Add policies: `secretsmanager:GetSecretValue`, `secretsmanager:PutSecretValue`, etc.   |

