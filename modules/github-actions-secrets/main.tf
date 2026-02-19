resource "github_actions_secret" "this" {
  repository      = var.repo_name
  secret_name     = var.name
  plaintext_value = var.value
}
