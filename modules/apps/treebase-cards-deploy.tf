data "kubernetes_secret" "treebase_cards_deployer" {
  metadata {
    name      = "rook-ceph-object-user-hasadna-digital-forest-cards-site-deployer"
    namespace = "treebase"
  }
}

resource "github_actions_secret" "digital-forest-cards" {
  for_each = {
    DEPLOY_S3_ACCESS_KEY_ID = data.kubernetes_secret.treebase_cards_deployer.data.AccessKey
    DEPLOY_S3_SECRET_ACCESS_KEY = data.kubernetes_secret.treebase_cards_deployer.data.SecretKey
    DEPLOY_S3_ENDPOINT = "https://rgw.rke2.hasadna.org.il"
  }
  repository = "digital-forest-cards"
  secret_name = each.key
  plaintext_value = each.value
}
