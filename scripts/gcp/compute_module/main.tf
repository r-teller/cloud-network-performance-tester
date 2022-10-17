resource "random_id" "id" {
  byte_length = 2
}

module "gcp_utils" {
  source  = "terraform-google-modules/utils/google"
  version = "~> 0.3"
}

locals {
  region_longname  = regex("projects/.*/regions/(?P<region>[^/]*)/*", var.subnetwork).region
  region_shortname = module.gcp_utils.region_short_name_map[lower(local.region_longname)]
  zone             = var.zone != null ? var.zone : data.google_compute_zones.available[0].names[0]
}

data "google_compute_zones" "available" {
  count = var.zone == null ? 1 : 0

  region  = local.region_longname
  project = var.project_id
}

resource "google_compute_instance" "instance" {
  provider = google-beta

  name         = "cnpt-${local.region_shortname}-${random_id.id.hex}"
  machine_type = var.machine_type
  zone         = local.zone
  project      = var.project_id

  metadata_startup_script = file("${path.module}/metadata_startup_script")

  boot_disk {
    initialize_params {
      image = var.book_disk_image
      type  = var.boot_disk_type
    }
  }

  dynamic "scratch_disk" {
    for_each = var.scratch_disk ? [1] : []
    content {
      interface = "SCSI"
    }
  }

  network_interface {
    subnetwork = var.subnetwork

    nic_type   = var.nic_type
    stack_type = var.ip_stack_type
    dynamic "access_config" {
      for_each = var.external_ip ? [1] : []
      content {
        network_tier = "PREMIUM"
      }
    }
  }

  network_performance_config {
    total_egress_bandwidth_tier = var.egress_bandwidth_tier
  }

  scheduling {
    provisioning_model = "STANDARD"

  }
}
