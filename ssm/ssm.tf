resource "aws_ssm_parameter" "neo4j_uri" {
  name        = "/ticket/neo4j/uri"
  description = "The URI for the Neo4j database"
  type        = "SecureString"
  value       = var.neo4j_uri

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "neo4j_user" {
  name        = "/ticket/neo4j/user"
  description = "The username for the Neo4j database"
  type        = "SecureString"
  value       = var.neo4j_user

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "neo4j_password" {
  name        = "/ticket/neo4j/password"
  description = "The password for the Neo4j database"
  type        = "SecureString"
  value       = var.neo4j_password

  lifecycle {
    ignore_changes = [value]
  }
}
