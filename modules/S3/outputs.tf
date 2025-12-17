// filepath: c:\Users\mateu\GolandProjects\infra\S3\outputs.tf

output "bucket_id" {
  description = "ID (nome) do bucket S3"
  value       = aws_s3_bucket.this.id
}

output "bucket_name" {
  description = "Nome do bucket S3 (alias para bucket_id)"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Nome de domínio do bucket (ex: bucket.s3.amazonaws.com)"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Nome de domínio regional do bucket (ex: bucket.s3.region.amazonaws.com)"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
