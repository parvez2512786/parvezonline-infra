# parvezonline-infra

Terraform infrastructure for parvezonline.com demo:
- EC2 (t3.large) in default VPC (us-east-1)
- Security Group (22 from my IP, 80/443 public)
- Elastic IP
- Route53 Public Hosted Zone for parvezonline.com

## Run
cd terraform/aws-foundation
terraform init
terraform plan
terraform apply

## Notes
- `terraform.tfvars` and `*.tfstate` are intentionally NOT committed.
