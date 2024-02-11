output "task_role_arn" {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}

output "iam_instance_profile" {
  value = aws_iam_instance_profile.ecs_instance_profile.arn
}