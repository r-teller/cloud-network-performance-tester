module "test" {
  source     = "./compute_module"

  subnetwork = var.subnetwork
  project_id = var.project_id
}

variable "subnetwork" {
  description = "Name of the subnetwork this instance should use to."
}

variable "project_id" {
  description = "Project id of the project that holds the network."
}

output "instance_name" {
  value = module.test.instance_name
}