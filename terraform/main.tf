# ============================================================
# Terraform 設定區塊：指定所需的 Provider 版本
# ============================================================
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    # 使用 Google Cloud Provider 來管理 GCP 資源
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ============================================================
# Provider 設定：指定要操作的 GCP 專案與區域
# ============================================================
provider "google" {
  project = var.project_id
  region  = var.region
}

# ============================================================
# VPC 網路：建立自訂的虛擬私有網路（不使用 GCP 預設網路）
# auto_create_subnetworks = false 表示我們要手動建立子網路
# ============================================================
resource "google_compute_network" "vpc" {
  name                    = "sre-vpc"
  auto_create_subnetworks = false
  description             = "SRE 專用 VPC 網路"
}

# ============================================================
# Subnet 子網路：在 VPC 中建立一個子網路
# 指定 IP 範圍，並啟用 GKE 所需的次要 IP 範圍
# （Pod 和 Service 各需要一個獨立的 IP 範圍）
# ============================================================
resource "google_compute_subnetwork" "subnet" {
  name          = "sre-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.0.0/24"

  # Pod 使用的次要 IP 範圍
  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.20.0.0/16"
  }

  # Service 使用的次要 IP 範圍
  secondary_ip_range {
    range_name    = "service-range"
    ip_cidr_range = "10.30.0.0/20"
  }
}

# ============================================================
# GKE 集群：建立 Kubernetes 集群
# 使用 VPC 原生路由（IP Alias），將 Pod/Service 網段
# 對應到 Subnet 的次要 IP 範圍
# ============================================================
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone
  deletion_protection = false

  # 使用自訂的 VPC 和子網路
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  # 移除預設節點池，改用獨立的節點池資源管理
  # 這樣可以更靈活地調整節點池設定
  remove_default_node_pool = true
  initial_node_count       = 1

  # 啟用 VPC 原生路由，指定 Pod 和 Service 的 IP 範圍
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-range"
    services_secondary_range_name = "service-range"
  }

  # 啟用網路策略（Network Policy）以增強安全性
  network_policy {
    enabled = true
  }
}

# ============================================================
# GKE 節點池：定義工作節點的規格與數量
# 獨立管理節點池，方便日後擴縮容或變更機器型號
# ============================================================
resource "google_container_node_pool" "primary_nodes" {
  name     = "sre-node-pool"
  location = var.zone
  cluster  = google_container_cluster.primary.name

  # 節點數量
  node_count = var.node_count

  # 節點規格設定
  node_config {
    machine_type = var.machine_type
    disk_size_gb = 30
    disk_type    = "pd-standard"

    # 設定節點的 OAuth 範圍，允許存取必要的 GCP 服務
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    # 節點標籤，用於識別節點用途
    labels = {
      env = "dev"
    }
  }
}
