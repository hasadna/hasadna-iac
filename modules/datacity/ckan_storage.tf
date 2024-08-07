resource "google_storage_bucket" "ckan_instance_storage" {
  for_each = { for site in local.sites : site.name => site }
  name = "datacity-${each.key}"
  location = "europe-west1"
  cors {
    max_age_seconds = 3600
    method = ["GET", "HEAD", "OPTIONS"]
    origin = ["*"]
    response_header = ["*"]
  }
}

resource "google_service_account" "ckan_instance_storage" {
  for_each = { for site in local.sites : site.name => site }
  account_id = "datacity-storage-${each.key}"
  display_name = "datacity-storage-${each.key}"
}

resource "terraform_data" "ckan_instance_storage_hmac" {
    for_each = { for site in local.sites : site.name => site }
    triggers_replace = {
        v = 1
    }
    provisioner "local-exec" {
        command = "python3 ${path.module}/create_hmac_key.py ${google_service_account.ckan_instance_storage[each.key].email} Projects/datacity/sites/${each.key}/storage-iac"
    }
}

resource "google_storage_bucket_iam_policy" "ckan_instance_storage" {
  for_each = { for site in local.sites : site.name => site }
  bucket = "datacity-${each.key}"
  policy_data = jsonencode({
    bindings = [
      {
        role = "roles/storage.legacyBucketOwner",
        members = [
          "projectEditor:datacity-k8s",
          "projectOwner:datacity-k8s"
        ]
      },
      {
        role = "roles/storage.legacyBucketReader",
        members = [
          "projectViewer:datacity-k8s"
        ]
      },
      {
        role = "roles/storage.objectAdmin",
        members = [
          "serviceAccount:${google_service_account.ckan_instance_storage[each.key].email}"
        ]
      }
    ]
  })
}
