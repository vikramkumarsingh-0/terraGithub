resource "github_branch_protection" "main" {
  repository_id = var.repo_id
  pattern       = "main"

  required_status_checks {
    strict = true
  }

  enforce_admins = true
}
