variable "region" {
  type    = string
  default = ""
}


variable "identifier" {
  type    = string
  default = ""
}

variable "project" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "tags" {
  default = {}
}

variable "ecs-cluster" {
  type    = any
  default = {}
}


variable "alb" {
  type    = any
  default = {}
}

variable "fargate_capacity_providers" {

}
variable "name_space" {

}
variable "service-db" {

}
variable "service-redis" {

}
variable "service-appserver" {

}
variable "service-ui" {

}