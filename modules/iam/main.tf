# Task executoin role
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = var.task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name    = var.name
    Creator = var.creator_name
    Project = var.project_name
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM instance profile 
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.ecs_role.name
}

resource "aws_iam_role" "ecs_role" {
  name               = var.instance_profile_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs_policy_attachment" {
  name       = aws_iam_instance_profile.ecs_instance_profile.name
  roles      = [aws_iam_role.ecs_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}