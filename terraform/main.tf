# ============================================================
# Terraform Configuration: Specify required provider versions
# ============================================================
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    # Use Google Cloud Provider to manage GCP resources
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ============================================================
# Provider Configuration: Specify the GCP project and region
# ============================================================
provider "google" {
  project = var.project_id
  region  = var.region
}

# ============================================================
# VPC Network: Create a custom Virtual Private Cloud
# auto_create_subnetworks = false means we manually create subnets
# ============================================================
resource "google_compute_network" "vpc" {
  name                    = "sre-vpc"
  auto_create_subnetworks = false
  description             = "SRE dedicated VPC network"
}

# ============================================================
# Subnet: Create a subnet within the VPC
# Define IP ranges and enable secondary IP ranges required by GKE
# ============================================================
resource "google_compute_subnetwork" "subnet" {
  name          = "sre-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.0.0/24"

  # Secondary IP range for Pods
  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.20.0.0/16"
  }

  # Secondary IP range for Services
  secondary_ip_range {
    range_name    = "service-range"
    ip_cidr_range = "10.30.0.0/20"
  }
}

# ============================================================
# GKE Cluster: Create the Kubernetes cluster
# Uses VPC-native routing (IP Alias) to map Pod/Service ranges
# to the subnet's secondary IP ranges
# ============================================================
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone
  deletion_protection = false

  # Use custom VPC and subnet
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  # Remove the default node pool and use a separately managed node pool
  # This allows more flexible node pool configuration
  remove_default_node_pool = true
  initial_node_count       = 1

  # Enable VPC-native routing, specify Pod and Service IP ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-range"
    services_secondary_range_name = "service-range"
  }

  # Enable Network Policy for enhanced security
  network_policy {
    enabled = true
  }
}

# ============================================================
# GKE Node Pool: Define worker node specifications and count
# Managed separately for easier scaling and machine type changes
# ============================================================
resource "google_container_node_pool" "primary_nodes" {
  name     = "sre-node-pool"
  location = var.zone
  cluster  = google_container_cluster.primary.name

  # Number of nodes
  node_count = var.node_count

  # Node configuration
  node_config {
    machine_type = var.machine_type
    disk_size_gb = 30
    disk_type    = "pd-standard"

    # Set OAuth scopes to allow access to necessary GCP services
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    # Node labels to identify node purpose
    labels = {
      env = "dev"
    }
  }
}
