resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  project                  = var.project_id
  ip_cidr_range            = var.cidr_range
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = var.private_ip_google_access
}

resource "google_compute_firewall" "allow-internal" {
  name    = var.firewall_name
  network = google_compute_network.vpc.self_link
  project = var.project_id

  dynamic "allow" {
    for_each = var.firewall_rules
    content {
      protocol = allow.value["protocol"]
      ports    = lookup(allow.value, "ports", [])
    }

  }

  source_ranges = var.source_ranges

  depends_on = [google_compute_network.vpc, google_compute_subnetwork.subnet]
}
