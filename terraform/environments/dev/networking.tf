module "vpc" {
  source        = "./../../modules/networking"
  name          = "vpc-${var.environment}"
  cidr_range    = "${local.cidr_prefix_map}.0.0/22"
  subnet_name   = "private-subnet-1"
  source_ranges = ["${local.cidr_prefix_map}.0.0/22"]
  firewall_name = "dataflow"
  project_id    = var.project_id
  firewall_rules = [{
    protocol = "tcp"
    ports    = ["443", "80"]
  }]
}
