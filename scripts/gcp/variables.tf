variable "subnetwork" {
  description = "Name of the subnetwork this instance should use to."
}

variable "project_id" {
  description = "Project id of the project that holds the network."
}

variable "zone" {
  default = null
  type    = string
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "book_disk_image" {
  default = "debian-cloud/debian-11"
  type    = string
}
variable "boot_disk_type" {
  type    = string
  default = "pd-standard"
  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd"], var.boot_disk_type)
    error_message = "One or more strings in var.boot_disk_type is not supported, supported strings are [ pd-standard, pd-balanced, pd-ssd]"
  }

}
variable "scratch_disk" {
  type    = bool
  default = false
}

variable "external_ip" {
  type    = bool
  default = false
}

variable "egress_bandwidth_tier" {
  type    = string
  default = "DEFAULT"
  validation {
    condition     = contains(["TIER_1", "DEFAULT"], var.egress_bandwidth_tier)
    error_message = "One or more strings in var.egress_bandwidth_tier is not supported, supported strings are [TIER_1, DEFAULT]"
  }

}

variable "ip_stack_type" {
  type    = string
  default = "IPV4_ONLY"
  validation {
    condition     = contains(["IPV4_ONLY", "IPV4_IPV6"], var.ip_stack_type)
    error_message = "One or more strings in var.ip_stack_type is not supported, supported strings are [IPV4_ONLY, IPV4_IPV6]"
  }
}

variable "nic_type" {
  type    = string
  default = "VIRTIO_NET"
  validation {
    condition     = contains(["VIRTIO_NET", "GVNIC"], var.nic_type)
    error_message = "One or more strings in var.nic_type is not supported, supported strings are [VIRTIO_NET, GVNIC]"
  }

}
