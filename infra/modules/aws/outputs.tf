output "kms_key_arn" { value = aws_kms_key.application.arn }
output "audit_bucket_name" { value = aws_s3_bucket.audit.id }
output "application_secret_arn" { value = aws_secretsmanager_secret.application.arn }

