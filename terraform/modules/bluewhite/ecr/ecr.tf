resource "aws_ecr_repository" "repo" {
  for_each             = toset(toset(var.ecr_repository_name))
  name                 = each.value
  image_tag_mutability = var.image_tag_mutability

  # Image scanning configuration
  dynamic "image_scanning_configuration" {
    for_each = local.image_scanning_configuration
    content {
      scan_on_push = lookup(image_scanning_configuration.value, "scan_on_push")
    }
  }

  # Timeouts
  dynamic "timeouts" {
    for_each = local.timeouts
    content {
      delete = lookup(timeouts.value, "delete")
    }
  }

  # Tags
  tags = {
    Owner       = "develeap"
    Environment = "dev"
    Terraform   = true
  }

}

# Policy
resource "aws_ecr_repository_policy" "policy" {
  for_each = toset(var.ecr_repository_name)
  repository = aws_ecr_repository.repo[each.key].name
  policy     = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "repo policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

# Lifecycle policy
resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  for_each = toset(var.ecr_repository_name)
  repository = aws_ecr_repository.repo[each.key].name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep last 30 dev images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["dev"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}