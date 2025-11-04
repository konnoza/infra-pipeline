variable "github_organization_name" {
  description = "The name of Github organization."
  type        = string
}

variable "github_repository_name" {
  description = "The name of Github reposiroty."
  type        = string
}

variable "github_branch" {
  description = "List of Github Entity environment"
  type        = set(string)
}