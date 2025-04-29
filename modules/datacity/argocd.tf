resource "google_service_account" "argocd_gke_auth" {
  account_id   = "argocd-gke-auth"
  display_name = "ArgoCD-external"
}

resource "google_project_iam_member" "argocd_gke_auth" {
  for_each = toset([
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.workloadIdentityUser",
    "roles/container.clusterAdmin",
  ])
  project = "datacity-k8s"
  role    = each.value
  member  = "serviceAccount:${google_service_account.argocd_gke_auth.email}"
}

resource "google_service_account_key" "argocd_gke_auth_key" {
  service_account_id = google_service_account.argocd_gke_auth.name
}

data "google_container_cluster" "datacity" {
  name     = "datacity"
  location = "europe-west1-d"
}

# Create the following secrets manually

# resource "kubernetes_secret" "argocd_gke_auth_token" {
#     metadata {
#         name      = "gke-auth-datacity"
#         namespace = "argocd"
#     }
#     data = {
#         auth.json = base64encode(google_service_account_key.argocd_gke_auth_key.private_key)
#     }
#     type = "Opaque"
# }

# resource "kubernetes_secret" "argocd_gke_cluster" {
#   metadata {
#     name = "cluster-datacity"
#     namespace = "argocd"
#     labels = {
#       "argocd.argoproj.io/secret-type" = "cluster"
#     }
#   }
#   data = {
#     name = base64encode("datacity")
#     server = base64encode("https://${data.google_container_cluster.datacity.endpoint}")
#     config = base64encode(jsonencode({
#       "tlsClientConfig": {
#         "insecure": true
#       },
#       "execProviderConfig": {
#         "command": "/opt/google-cloud-sdk/bin/gke-gcloud-auth-plugin",
#         "args": ["--use_application_default_credentials"],
#         "apiVersion": "client.authentication.k8s.io/v1beta1"
#       }
#     }))
#   }
# }
