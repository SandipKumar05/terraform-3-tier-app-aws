## Terraform Setup for Creating S3 Bucket and DynamoDB Table

### Note:

- This Terraform configuration is a one-time setup.
- It will create an S3 bucket and a DynamoDB table.
- **S3 Bucket**: Stores the state file of Terraform.
- **DynamoDB Table**: Used for state locking in Terraform operations.
- **SSH Key Pair**: Required for SSH purposes.