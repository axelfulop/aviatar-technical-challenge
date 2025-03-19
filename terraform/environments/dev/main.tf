terraform {
  cloud {
    organization = "aviatar-challenge"

    workspaces {
      name = "aviatar-dev"
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.25.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
#
