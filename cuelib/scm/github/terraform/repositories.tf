# Operate repositories

variable "repo_name" {
  type = string
}

variable "repo_visibility" {
  type = string
}

variable "github_token" {
  type = string
}

resource "github_repository" "initRepo" {
  name        = var.repo_name
  description = "A repo created by Heighliner"

  # Private or public
  visibility = var.repo_visibility
}

output "repo_url" {
  value = github_repository.initRepo.html_url
}

# Set github token as github action secret.
resource "github_actions_secret" "secret_PAT" {
  repository = github_repository.initRepo.id
  secret_name = "PAT"
  plaintext_value = var.github_token
}

# Get profile of current authenticated user.
data "github_user" "currentUser" {
  username = ""
}

output "userEmail" {
  value = data.github_user.currentUser.email
}

output "userFullName" {
  value = data.github_user.currentUser.name
}