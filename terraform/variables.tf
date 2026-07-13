# ============================================================
# Variable Definitions: Centralized management of configurable parameters
# ============================================================

# GCP Project ID - must be changed to your own project ID before deployment
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

# GCP region for deployment, defaults to Taiwan region for lower latency
variable "region" {
  description = "GCP deployment region"
  type        = string
  default     = "asia-east1"
}

# GKE node availability zone
variable "zone" {
  description = "GCP availability zone"
  type        = string
  default     = "asia-east1-a"
}

# GKE cluster name
variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "sre-gke-cluster"
}

# GKE node count, set to minimum to save costs
variable "node_count" {
  description = "GKE node count"
  type        = number
  default     = 2
}

# GKE node machine type, using e2-medium to save testing costs
variable "machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-medium"
}
