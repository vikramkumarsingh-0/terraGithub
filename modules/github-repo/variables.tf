variable "name" {}
variable "description" {}
variable "visibility" { default = "private" }
variable "topics" { type = list(string) }
