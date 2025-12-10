variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instance access"
  type        = string
}

variable "neo4j_password" {
  description = "Password for Neo4j database (username will be 'neo4j')"
  type        = string
  sensitive   = true
}
