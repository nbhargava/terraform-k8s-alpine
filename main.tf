# // provider.tf

variable project_name {
  default = "<insert project name>"
}

variable zone {
  default = "us-central1-b"
}

provider "google" {
  credentials = file("./creds")
  project     = var.project_name
  zone        = var.zone
}


// gkecluster.tf

data "google_client_config" "current" {}

resource "google_compute_network" "default" {
  name                    = var.project_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name                     = var.project_name
  ip_cidr_range            = "10.127.0.0/20"
  network                  = google_compute_network.default.self_link
  private_ip_google_access = true
}

data "google_container_engine_versions" "default" {}

resource "google_container_cluster" "default" {
  name               = "gke-${var.project_name}"
  initial_node_count = 3
  min_master_version = data.google_container_engine_versions.default.latest_master_version
  network            = google_compute_subnetwork.default.name
  subnetwork         = google_compute_subnetwork.default.name
}


provider "k8s" {
  host                   = google_container_cluster.default.endpoint
  token                  = data.google_client_config.current.access_token
  client_certificate     = base64decode(google_container_cluster.default.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster.default.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)
}

resource "k8s_manifest" "dummy" {
  content = file("${path.module}/foo.yaml")
}
