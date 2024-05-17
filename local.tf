locals {
  identifier = "${var.identifier}-${var.environment}-${var.region}"
  tags       = merge({ Terraform = "true" }, var.tags)

}
