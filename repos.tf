variable "repositories" {
  type = map(object({
    description = string
    visibility  = string
    topics      = list(string)
  }))
}

module "repos" {
  source = "./modules/github-repo"

  for_each = var.repositories

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility
  topics      = each.value.topics
}
