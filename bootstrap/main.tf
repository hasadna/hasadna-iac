terraform {
  required_version = ">=1.9.3"
  backend "pg" {}
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.40.0"
    }
  }
}

provider "google" {
  project = "datacity-k8s"
  region = "europe-west1"
}

resource "google_service_account" "terraform" {
  account_id   = "hasadna-iac-terraform"
  display_name = "hasadna-iac-terraform"
}

resource "google_project_iam_custom_role" "terraform" {
    role_id     = "hasadna_iac_terraform"
    title = "hasadna_iac_terraform"
    permissions = [
        "compute.instanceGroupManagers.get",
        "container.clusters.get",
        "iam.serviceAccountKeys.create",
        "iam.serviceAccountKeys.get",
        "iam.serviceAccounts.create",
        "iam.serviceAccounts.get",
        "resourcemanager.projects.getIamPolicy",
        "resourcemanager.projects.setIamPolicy",
        "storage.buckets.create",
        "storage.buckets.get",
        "storage.buckets.getIamPolicy",
        "storage.buckets.setIamPolicy",
        "storage.hmacKeys.create"
    ]
}

resource "google_project_iam_member" "terraform" {
  project = "datacity-k8s"
  role    = google_project_iam_custom_role.terraform.name
  member  = "serviceAccount:${google_service_account.terraform.email}"
}
