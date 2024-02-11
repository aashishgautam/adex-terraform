# ---ecs/module/main.tf---

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
  tags = {
    Terraform   = "true"
    Environment = var.environment
    Name = var.name
    Project = var.project_name
    Creator = var.creator_name
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
