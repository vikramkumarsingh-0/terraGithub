resource "github_issue_label" "labels" {
  for_each = toset(var.labels)

  repository = var.repo
  name       = each.value
  color      = "ededed"
}
