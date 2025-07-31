```markdown
# 🔐 SecuritySecretsIAM

This project demonstrates real-world AWS security and IAM patterns through a **custom Secrets Manager Rotation Lambda**, managed via **Terraform**. It’s part of my 2-month cloud job readiness journey.

---

## ✅ What This Project Covers

- **Custom Secrets Rotation Lambda** using `rotation.py`
- **Terraform** deployment for:
  - Secrets Manager with automatic rotation
  - Lambda function and IAM roles
- **IAM security best practices**
  - Scoped-down Lambda execution role
  - Rotation-specific permissions
- **CloudWatch Logs** for debugging rotation failures
- **Hands-on debugging experience**:
  - `Runtime.ImportModuleError`
  - `A previous rotation isn't complete`
  - Lambda packaging pitfalls (`rotation.py` import errors)

---

## 📁 Project Structure

```

lesson-4-secrets-security/
├── main.tf               # Secret, IAM, rotation schedule
├── lambda.tf             # Lambda deployment & role
├── outputs.tf
├── rotation.py           # Rotation script
├── zip.sh                # Script to zip Lambda
├── .gitignore
└── README.md

````

---

## 🚀 How to Deploy

```bash
# 1. Zip the Lambda rotation handler
bash zip.sh

# 2. Deploy with Terraform
terraform init
terraform apply

# 3. Manually trigger secret rotation (if needed)
aws secretsmanager rotate-secret --secret-id lesson4-api-key
````

---

## ⚠️ Known Issues & Lessons Learned

| Issue                            | Resolution Attempted                                                              |
| -------------------------------- | --------------------------------------------------------------------------------- |
| `No module named 'rotation'`     | Make sure `rotation.py` is zipped **at root**, not inside a folder.               |
| `Previous rotation not complete` | Used `cancel-rotate-secret` before retrying. Sometimes AWS requeues retry anyway. |
| Rotation handler not invoked     | Confirmed Lambda logs and IAM role permissions.                                   |
| Realistic IAM practice           | Created scoped Lambda role for rotation with only required permissions.           |

---

## 🧠 What I Learned

* **Secrets Manager internals** — how AWS invokes rotation Lambdas with 4-step stages.
* **IAM troubleshooting** — how to debug missing `secretsmanager:GetSecretValue` or `secretsmanager:PutSecretValue`.
* **Lambda packaging** — zip structure matters; packaging mistakes cause `ImportModuleError`.
* **Fail-safe Terraform** — reused working rotation.py and zipped fresh with every retry.
* **Security-first thinking** — minimal permissions, canceling stuck rotations, and using CloudWatch to trace errors.

---

## 💡 Next Steps

* Retry rotation later after cooldown (AWS caches failed rotation attempts).
* Add KMS key + encryption-in-transit for full security deep dive (optional).
* Explore multi-region secrets or fine-grained secret scopes (microservices).

---

## 🧼 Clean Up (to avoid AWS charges)

```bash
terraform destroy
```

---

## 🔗 Repo

[https://github.com/Syamel111/SecuritySecretsIAM](https://github.com/Syamel111/SecuritySecretsIAM)

---

## 📅 Project Type

**Mini Project 3 — Security, Secrets, IAM Edge Cases**
Part of 2-month AWS cloud job readiness plan


---

## 🔁 Mini Project 3 – Secrets Rotation (Retry Attempt)

### ⏪ Purpose of Retry

After completing Mini Project 3 (Secrets Rotation using AWS Secrets Manager and Lambda), a retry was attempted to:

* Rebuild the full infrastructure from scratch using Terraform
* Fix the previous **AccessDeniedException** related to Lambda trust policies
* Manually trigger and observe a successful secret rotation cycle

---

### ✅ Changes Implemented in Retry

* **Recreated all secrets infrastructure via Terraform**:

  * `aws_secretsmanager_secret`
  * `aws_lambda_function` (custom rotation Lambda)
  * `aws_secretsmanager_secret_rotation` resource
* **IAM trust policy updated** to allow `secretsmanager.amazonaws.com` to invoke the Lambda:

  ```hcl
  statement {
    effect = "Allow"
    actions = ["lambda:InvokeFunction"]
    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_secretsmanager_secret.rotating_secret.arn]
    }
  }
  ```

---

### ⚠️ Rotation Failure (Again)

Despite the correct IAM setup and successful apply of all resources, rotation still failed with the error:

```
Failed to rotate the secret "MyRotatingSecret".
A previous rotation isn't complete. That rotation will be reattempted.
```

Additional checks revealed:

* No new version in Secrets Manager (`AWSPENDING` version missing)
* The stuck state persisted even after disabling and re-enabling rotation
* No way to forcefully cancel the ongoing (stuck) rotation from the console or API

---

### ❌ Outcome

* **No successful rotation occurred**
* Rotation remained **stuck due to an incomplete previous cycle**
* Decided **not to push the retry code** to GitHub, as it’s functionally the same as the first version

---

### ✅ Lessons Learned

* Gained deeper understanding of how **Secrets Manager rotation state works**
* Practiced full **Terraform infrastructure rebuild** and teardown
* Identified the exact trust relationship needed for Secrets Manager to invoke Lambda
* Realized AWS does **not allow aborting a stuck rotation cycle manually**, making some failures unrecoverable without a new secret

---

### 📌 Takeaway

This retry reinforced the realities of production cloud infrastructure:

* Some issues (like a stuck rotation) may require **abandoning the resource** entirely
* It's crucial to test rotation logic early and thoroughly before enabling it in production
* Managing stateful AWS services like Secrets Manager involves **more than just Terraform**—manual intervention is sometimes needed

---
