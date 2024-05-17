resource "aws_iam_policy" "service_con_policy" {
  name        = "service_con_policy"
  description = "Policy to access ECR and ELB"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:RegisterTargets"
        ],
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}


resource "aws_iam_role" "service_con_role" {
  name = "service_con_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ECSTaskExecutionAssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "service_con_policy_attachment" {
  role       = aws_iam_role.service_con_role.name
  policy_arn = aws_iam_policy.service_con_policy.arn
}


resource "aws_service_discovery_http_namespace" "cloudmap_namespace" {
  name        = var.name_space
  description = "Namespace for the service communication."
  tags = {
    "AmazonECSManaged" : true
  }
}

module "postgress-db" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.11.1"

  cluster_name               = var.ecs-cluster.cluster_name
  fargate_capacity_providers = var.fargate_capacity_providers

  services = {
    postgress-server = {
      name                           = "${local.identifier}-${var.service-db.name}"
      cpu                            = var.service-db.cpu
      memory                         = var.service-db.memory
      assign_public_ip               = var.service-db.assign_public_ip
      subnet_ids                     = ["subnet-0fa17ac070f6c04dd", "subnet-050f44f6bb6950b8e"]
      security_group_name            = "${local.identifier}-${var.service-db.name}-sg"
      security_group_use_name_prefix = var.service-db.security_group_use_name_prefix
      security_group_description     = var.service-db.security_group_description
      security_group_rules           = var.service-db.security_group_rules
      task_exec_iam_role_arn         = aws_iam_role.service_con_role.arn
      container_definitions          = var.service-db.container_definitions

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.cloudmap_namespace.name
        service   = var.service-db.service_connect_configuration.service

      }
    }
  }
}

module "redis-server" {
  source                      = "terraform-aws-modules/ecs/aws"
  version                     = "5.11.1"
  cluster_name                = var.ecs-cluster.cluster_name
  create_cloudwatch_log_group = false

  services = {
    redis-server = {
      name                           = "${local.identifier}-${var.service-redis.name}"
      cpu                            = var.service-redis.cpu
      memory                         = var.service-redis.memory
      assign_public_ip               = var.service-redis.assign_public_ip
      subnet_ids                     = ["subnet-0fa17ac070f6c04dd", "subnet-050f44f6bb6950b8e"]
      security_group_name            = "${local.identifier}-${var.service-db.name}-sg"
      security_group_use_name_prefix = var.service-redis.security_group_use_name_prefix
      security_group_description     = var.service-redis.security_group_description
      security_group_rules           = var.service-redis.security_group_rules
      task_exec_iam_role_arn         = aws_iam_role.service_con_role.arn
      container_definitions          = var.service-redis.container_definitions

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.cloudmap_namespace.name
        service   = var.service-redis.service_connect_configuration.service

      }
    }
  }
}

module "app-server" {
  source       = "terraform-aws-modules/ecs/aws"
  version      = "5.11.1"
  cluster_name = var.ecs-cluster.cluster_name

  create_cloudwatch_log_group = false

  services = {
    app-server = {
      name                           = "${local.identifier}-${var.service-appserver.name}"
      cpu                            = var.service-appserver.cpu
      memory                         = var.service-appserver.memory
      assign_public_ip               = var.service-appserver.assign_public_ip
      subnet_ids                     = ["subnet-0fa17ac070f6c04dd", "subnet-050f44f6bb6950b8e"]
      security_group_name            = "${local.identifier}-${var.service-db.name}-sg"
      security_group_use_name_prefix = var.service-appserver.security_group_use_name_prefix
      security_group_description     = var.service-appserver.security_group_description
      security_group_rules           = var.service-appserver.security_group_rules
      task_exec_iam_role_arn         = aws_iam_role.service_con_role.arn
      container_definitions          = var.service-appserver.container_definitions

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.cloudmap_namespace.name
        service   = var.service-appserver.service_connect_configuration.service

      }
    }
  }
  depends_on = [module.postgress-db, module.redis-server]
}

module "ui-server" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.11.1"

  cluster_name                = var.ecs-cluster.cluster_name
  create_cloudwatch_log_group = false
  services = {
    ui-server = {
      name                           = "${local.identifier}-${var.service-ui.name}"
      cpu                            = var.service-ui.cpu
      memory                         = var.service-ui.memory
      assign_public_ip               = var.service-ui.assign_public_ip
      subnet_ids                     = ["subnet-0fa17ac070f6c04dd", "subnet-050f44f6bb6950b8e"]
      security_group_name            = "${local.identifier}-${var.service-db.name}-sg"
      security_group_use_name_prefix = var.service-ui.security_group_use_name_prefix
      security_group_description     = var.service-ui.security_group_description
      security_group_rules           = var.service-ui.security_group_rules
      task_exec_iam_role_arn         = aws_iam_role.service_con_role.arn
      container_definitions          = var.service-ui.container_definitions
      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["ex_ecs"].arn
          container_name   = var.service-ui.load_balancer.service.container_name
          container_port   = var.service-ui.load_balancer.service.container_port
        }
      }
      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.cloudmap_namespace.name
        service   = var.service-ui.service_connect_configuration.service

      }
    }
  }
  depends_on = [module.app-server, module.alb]
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = var.alb.name

  load_balancer_type = var.alb.load_balancer_type

  vpc_id                     = "vpc-051aebfb09009a9c3"
  subnets                    = ["subnet-0fa17ac070f6c04dd", "subnet-050f44f6bb6950b8e"]
  enable_deletion_protection = var.alb.enable_deletion_protection

  security_group_ingress_rules = var.alb.security_group_ingress_rules
  security_group_egress_rules  = var.alb.security_group_egress_rules

  listeners = var.alb.listeners

  target_groups = var.alb.target_groups

  tags = local.tags
}



