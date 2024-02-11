## Elastic Container Repository
resource "aws_ecr_repository" "aws_ecr" {
  name = var.ecr_name

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name    = var.name
    Creator = var.creator_name
    Project = var.project_name
  }
}