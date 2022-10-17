
resource "google_compute_instance" "instance-1" {
  provider = google-beta

  name         = "instance-1"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  project      = "rteller-demo-svc-e265-aaaa"

  metadata_startup_script = file("./metadata_startup_script")

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      type  = "pd-standard"
    }
  }

  dynamic "scratch_disk" {
    # [] disable scratch disk / [1] enable scratch disk
    for_each = []
    content {
      interface = "SCSI"
    }
  }

  network_interface {
    subnetwork = "projects/rteller-demo-hst-e265-aaaa/regions/us-central1/subnetworks/default"

    nic_type   = "GVNIC"
    stack_type = "IPV4_ONLY"
    dynamic "access_config" {
      # [] disable external ip / [1] enable external ip
      for_each = []
      content {
        network_tier = "PREMIUM"
      }
    }
  }

  network_performance_config {
    total_egress_bandwidth_tier = "DEFAULT"
  }

  scheduling {
    provisioning_model = "STANDARD"

  }
}
