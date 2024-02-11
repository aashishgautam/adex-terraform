terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

module "network" {
  source                     = "../../modules/network"
  environment                = "prod"
  vpc_cidr                   = "10.19.0.0/16"
  vpc_name                   = "prod-us-east-2-vpc"
  gw_name                    = "prod-us-east-2-gw"
  nat_eip_name               = "prod-us-east-2-nat-eip"
  nat_gateway_name           = "prod-us-east-2-nat-gw"
  public_subnet_cidr_blocks  = ["10.19.1.0/24", "10.19.2.0/24"]
  private_subnet_cidr_blocks = ["10.19.3.0/24", "10.19.4.0/24"]
  availability_zones         = ["us-east-2a", "us-east-2b"]
  public_subnet_name_prefix  = "public-subnet-prod"
  private_subnet_name_prefix = "private-subnet-prod"
  public_rt_name             = "public-rt-prod"
  private_rt_name            = "private-rt-prod"
  sg_name                    = "prod-us-east-2-sg"
  creator_name               = "aashish"
  project_name               = "assignment"
}

module "elb" {
  source                = "../../modules/elb"
  environment           = "prod"
  alb_name              = "prod-alb"
  log_group_name        = "/aws/alb/prod-alb-access-logs"
  public_subnets        = module.network.public_subnet_ids
  alb_sg                = module.network.sg_id
  listener_port         = 80
  vpc_id                = module.network.vpc_id
  tg_name               = "prod-tg"
  tg_port               = 3000
  target_type           = "instance"
  healthy_threshold     = 2
  unhealthy_threshold   = 2
  health_check_interval = 30
  health_check_path     = "/"
  health_check_timeout  = 5
  creator_name          = "aashish"
  project_name          = "assignment"
}

module "ecs" {
  source       = "../../modules/ecs"
  environment  = "prod"
  cluster_name = "prod-us-east-2-ecs"
  project_name = "assignment"
  creator_name = "aashish"
  name         = "prod-ecs-cluster"
}

module "ecs-task-service" {
  source                            = "../../modules/ecs-task-service"
  ecs_cluster_id                    = module.ecs.ecs_cluster_id
  task_family                       = "nodejs-todo"
  container_definitions             = file("${path.module}/nodejs-todo.json")
  service_name                      = "nodejs-todo-prod"
  desired_count                     = 2
  deployment_max                    = 200
  deployment_min                    = 100
  container_name                    = "nodejs-todo-prod"
  container_port                    = 3000
  target_group_arn                  = module.elb.target_group_arn
  enable_deployment_circuit_breaker = false
  enable_rollback                   = false
  placement_constraint_type         = "memberOf"
  placement_constraint_expression   = "attribute:ecs.availability-zone in [us-east-2a, us-east-2b]" 
  task_role_arn                     = module.iam.task_role_arn
  network_mode                      = "bridge"
  enable_ecs_managed_tags           = true
  propagate_tags                    = "SERVICE"
  enable_execute_command            = false
  health_check_grace_period         = 60
  iam_role                          = "arn:aws:iam::*:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  creator_name                      = "aashish"
  name                              = "task-log"
  project_name                      = "assignment"
  task_log_group                    = "/aws/tasks/prod"
}

module "iam" {
  source                     = "../../modules/iam"
  name                       = "role-name"
  project_name               = "assignment"
  creator_name               = "aashish"
  task_execution_role_name   = "prod-task-execution-role-ecs"
  instance_profile_name      = "prod-instance-profile"
  instance_profile_role_name = "prod-instance-profile-role"
}

module "ecr" {
  source       = "../../modules/ecr"
  name         = "role-name"
  project_name = "assignment"
  creator_name = "aashish"
  ecr_name     = "prod-ecr"

}

module "asg" {
  source               = "../../modules/asg"
  ami_id               = "ami-0fd94748ae6f66327"
  launch_template_name = "prod-ecs-us-east-2-lt"
  environment          = "prod"
  instance_type        = "t2.micro"
  iam_instance_profile = module.iam.iam_instance_profile
  key_name             = "assignment"
  instance_name        = "prod-ecs-us-east-2-node"
  # user_data            = filebase64("ecs.sh")
  asg_name             = "prod-ecs-us-east-2-asg"
  min_size             = 1
  desired_capacity     = 2
  max_size             = 5
  subnet_ids           = module.network.private_subnet_ids
  project_name         = "assignment"
  creator_name         = "aashish"
  name                 = "prod-asg"
  sg_name_lt           = "prod-sg-lt" 
  vpc_id = module.network.vpc_id
}