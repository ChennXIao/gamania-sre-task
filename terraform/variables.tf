# ============================================================
# 變數定義檔：集中管理所有可調整的參數
# ============================================================

# GCP 專案 ID，部署前必須修改為你自己的專案 ID
variable "project_id" {
  description = "GCP 專案 ID"
  type        = string
}

# 部署的 GCP 區域，預設使用台灣區域以降低延遲
variable "region" {
  description = "GCP 部署區域"
  type        = string
  default     = "asia-east1"
}

# GKE 節點所在的可用區域
variable "zone" {
  description = "GCP 可用區域"
  type        = string
  default     = "asia-east1-a"
}

# GKE 集群名稱
variable "cluster_name" {
  description = "GKE 集群名稱"
  type        = string
  default     = "sre-gke-cluster"
}

# GKE 節點數量，最小設定以節省成本
variable "node_count" {
  description = "GKE 節點數量"
  type        = number
  default     = 2
}

# GKE 節點機器型號，使用 e2-medium 以節省測試成本
variable "machine_type" {
  description = "GKE 節點機器型號"
  type        = string
  default     = "e2-medium"
}
