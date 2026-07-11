# ============================================================
# 輸出變數：Terraform 執行完畢後顯示重要資訊
# 這些值可以用於後續的 Helm 部署或 CI/CD 流程
# ============================================================

# 輸出 GKE 集群名稱，用於 kubectl 連線
output "cluster_name" {
  description = "GKE 集群名稱"
  value       = google_container_cluster.primary.name
}

# 輸出集群所在區域
output "cluster_zone" {
  description = "GKE 集群所在區域"
  value       = google_container_cluster.primary.location
}

# 輸出集群的 API 端點，kubectl 會透過此端點與集群通訊
output "cluster_endpoint" {
  description = "GKE 集群 API 端點"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

# 輸出連線到集群所需的 gcloud 指令
output "get_credentials_command" {
  description = "取得 kubeconfig 的指令"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${var.project_id}"
}
