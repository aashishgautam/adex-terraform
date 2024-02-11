variable "ami_id" {
  type        = string
  description = "The AWS account ID of the owner of the AMI."
}

variable "launch_template_name" {
  type        = string
  description = "The name of the launch template."
}

variable "environment" {
  type        = string
  description = "The environment for the resources."
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type to use."
}

variable "iam_instance_profile" {
  type       = string
  description = "Instance profile role."
}
variable "key_name" {
  type        = string
  description = "The name of the EC2 key pair to use."
}

variable "instance_name" {
  description = "Name tag for instances."
}

# variable "user_data" {
#   type        = string
#   description = "The user data script to run on the instances."
# }

variable "asg_name" {
  type        = string
  description = "The name of the auto scaling group."
}

variable "min_size" {
  type        = number
  description = "The minimum size of the auto scaling group."
}

variable "desired_capacity" {
  type        = number
  description = "The desired capacity of the auto scaling group."
}

variable "max_size" {
  type        = number
  description = "The maximum size of the auto scaling group."
}

variable "subnet_ids" {
  description = "The IDs of the subnets in which to launch the instances."
}

variable "name" {
  description = "Tag name for the asg"
}

variable "project_name" {
  description = "Project name for the asg"
}

variable "creator_name" {
  description = "Creator name for the asg"
}

variable "sg_name_lt" {
  description = "Security group name for the asg"
}

variable "vpc_id" {
  
}
