resource "github_team" "team" {
  name = var.team_name
}

resource "github_team_repository" "access" {
  team_id   = github_team.team.id
  repository = var.repo
  permission = var.permission
}
