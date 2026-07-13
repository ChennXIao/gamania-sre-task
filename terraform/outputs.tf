# ============================================================
# Output Variables: Display important information after Terraform execution
# These values can be used for subsequent Helm deployment or CI/CD pipelines
# ============================================================

# Output GKE cluster name for kubectl connection
output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}

# Output the zone where the cluster is located
output "cluster_zone" {
  description = "GKE cluster zone"
  value       = google_container_cluster.primary.location
}

# Output the cluster API endpoint, used by kubectl to communicate with the cluster
output "cluster_endpoint" {
  description = "GKE cluster API endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

# Output the gcloud command needed to connect to the cluster
output "get_credentials_command" {
  description = "Command to obtain kubeconfig"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${var.project_id}"
}
