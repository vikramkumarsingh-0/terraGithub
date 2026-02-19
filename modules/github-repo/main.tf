resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  auto_init          = true
  delete_branch_on_merge = true
  has_issues         = true
  has_projects       = true
  has_wiki           = false

  topics = var.topics
}
