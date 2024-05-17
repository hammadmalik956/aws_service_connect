region      = "us-west-1"
environment = "stage"
identifier  = "bidfta"
project     = "ecs"

name_space = "svccon"
ecs-cluster = {
  cluster_name = "serv-con"
}
fargate_capacity_providers = {
  FARGATE = {
    default_capacity_provider_strategy = {
      weight = 50
    }
  }
  FARGATE_SPOT = {
    default_capacity_provider_strategy = {
      weight = 50
    }
  }
}

service-db = {
  name                           = "postgres-db"
  cpu                            = 1024
  memory                         = 4096
  assign_public_ip               = true
  security_group_name            = "postgres-db-sg"
  security_group_use_name_prefix = true
  security_group_description     = "postgres-db-sg"
  security_group_rules = {
    ingress_with_cidr_blocks = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    egress_with_cidr_blocks = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "egress"
    }
  }
  container_definitions = {
    container-1 = {
      name                     = "postgres-db"
      cpu                      = 512
      memory                   = 1024
      image                    = "mreferre/yelb-db:0.6"
      essential                = true
      readonly_root_filesystem = false
      port_mappings = [
        {
          name          = "postgres-db"
          containerPort = 5432
          hostPort      = 5432
          protocol      = "tcp"

        }
      ]
      environment = [
        {
          name  = "USER"
          value = "admin"
        }
      ]
    }

  }
  service_connect_configuration = {

    service = {
      client_alias = {
        port     = 5432
        dns_name = "yelb-db"
      }
      port_name      = "postgres-db"
      discovery_name = "yelb-db"
    }
  }


}
service-redis = {
  name                           = "redis-server"
  cpu                            = 1024
  memory                         = 4096
  assign_public_ip               = true
  security_group_name            = "redis-server-sg"
  security_group_use_name_prefix = true
  security_group_description     = "redis-server-sg"
  security_group_rules = {
    ingress_with_cidr_blocks = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    egress_with_cidr_blocks = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "egress"
    }
  }
  container_definitions = {
    container-1 = {
      name                     = "redis-server"
      cpu                      = 512
      memory                   = 1024
      image                    = "redis:4.0.2"
      essential                = true
      readonly_root_filesystem = false
      port_mappings = [
        {
          name          = "redis-server"
          containerPort = 6379
          hostPort      = 6379
          protocol      = "tcp"

        }
      ]
      environment = [
        {
          name  = "USER"
          value = "admin"
        }
      ]
    }

  }
  service_connect_configuration = {

    service = {
      client_alias = {
        port     = 6379
        dns_name = "redis-server"
      }
      port_name      = "redis-server"
      discovery_name = "redis-server"
    }
  }

}

service-appserver = {
  name                           = "app-server"
  cpu                            = 1024
  memory                         = 4096
  assign_public_ip               = true
  security_group_name            = "app-server-sg"
  security_group_use_name_prefix = true
  security_group_description     = "app-server-sg"
  security_group_rules = {
    ingress_with_cidr_blocks = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    egress_with_cidr_blocks = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "egress"
    }
  }

  container_definitions = {
    container-1 = {
      name                     = "app-server"
      cpu                      = 512
      memory                   = 1024
      image                    = "mreferre/yelb-appserver:0.7"
      essential                = true
      readonly_root_filesystem = false
      port_mappings = [
        {
          name          = "app-server"
          containerPort = 4567
          hostPort      = 4567
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      environment = [
        {
          name  = "USER"
          value = "admin"
        }
      ]

    }


  }
  service_connect_configuration = {

    service = {
      client_alias = {
        port     = 4567
        dns_name = "yelb-appserver"
      }
      port_name      = "app-server"
      discovery_name = "yelb-appserver"
    }
  }




}
service-ui = {
  name                           = "app-ui"
  cpu                            = 1024
  memory                         = 4096
  assign_public_ip               = true
  security_group_name            = "app-ui-sg"
  security_group_use_name_prefix = true
  security_group_description     = "app-ui-sg"
  security_group_rules = {
    ingress_with_cidr_blocks = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    egress_with_cidr_blocks = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "egress"
    }
  }
  container_definitions = {
    container-1 = {
      name                     = "app-ui"
      cpu                      = 512
      memory                   = 1024
      image                    = "mreferre/yelb-ui:0.10"
      essential                = true
      readonly_root_filesystem = false
      port_mappings = [
        {
          name          = "app-ui"
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      environment = [
        {
          name  = "USER"
          value = "admin"
        }
      ]

    }

  }

  service_connect_configuration = {

    service = {
      client_alias = {
        port     = 80
        dns_name = "yelb-ui"
      }
      port_name      = "app-ui"
      discovery_name = "yelb-ui"
    }
  }
  load_balancer = {
    service = {

      container_name = "app-ui"
      container_port = 80
    }
  }

}

alb = {
  name = "app-ui-alb"

  load_balancer_type = "application"

  enable_deletion_protection = false

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ex_ecs"
      }
    }
  }

  target_groups = {
    ex_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = "80"
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      #   health_check = {
      #     enabled             = true
      #     healthy_threshold   = 5
      #     interval            = 30
      #     matcher             = "200"
      #     path                = "/"
      #     port                =80
      #     protocol            = "HTTP"
      #     timeout             = 5
      #     unhealthy_threshold = 2
      #   }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }
}


