
resource "aws_launch_template" "launch_template" {
  name = var.launch_template_name
  tags = {
    Name = var.launch_template_name
    Environment = var.environment
    Creator = var.creator_name
    Project = var.project_name
  }
  image_id = var.ami_id
  iam_instance_profile {
    arn = var.iam_instance_profile
  }
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg_lt.id]
  key_name = var.key_name
  monitoring {
    enabled = true
  }
  tag_specifications {
    tags = {
      Name    = var.instance_name
      Creator = var.creator_name
      Project = var.project_name
    }

    resource_type = "instance"
  }

  user_data = base64encode (<<EOF
    #!/bin/bash
    echo "ECS_CLUSTER=dev-us-east-2-ecs" >> /etc/ecs/ecs.config
    echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=1h" >> /etc/ecs/ecs.config
    echo "ECS_ENABLE_TASK_IAM_ROLE=true" >> /etc/ecs/ecs.config
    sudo reboot
  EOF
  )
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = var.asg_name
  health_check_type = "EC2"
  launch_template      {
    id = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  max_instance_lifetime   = 604800
  default_cooldown  = 300
  metrics_granularity     = "1Minute"
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  vpc_zone_identifier  = var.subnet_ids

  tag {
    key = "Name"
    value = var.asg_name
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = var.environment
    propagate_at_launch = true
  }

  tag {
    key = "Creator"
    value = var.creator_name
    propagate_at_launch = true
  }

  tag {
    key = "Project"
    value = var.project_name
    propagate_at_launch = true
  }
}


resource "aws_security_group" "sg_lt" {
  name   = var.sg_name_lt
  vpc_id = var.vpc_id
  tags = {
    Name        = var.sg_name_lt
    Environment = var.environment
    Project     = var.project_name
    Creator     = var.creator_name
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}