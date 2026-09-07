resource "github_repository" "product" {
  name                   = var.repository_name
  description            = var.description
  visibility             = "private"
  has_issues             = true
  has_projects           = true
  vulnerability_alerts   = true
  delete_branch_on_merge = true
  allow_auto_merge       = true
}

resource "github_branch_protection" "main" {
  repository_id = github_repository.product.node_id
  pattern       = "main"

  enforce_admins                  = true
  require_conversation_resolution = true
  required_status_checks {
    strict   = true
    contexts = ["terraform", "api", "web"]
  }
  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

output "repository_url" { value = github_repository.product.html_url }

