variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Neo4j"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (Amazon Linux 2023 recommended)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name for instance access"
  type        = string
}

variable "neo4j_password" {
  description = "Initial password for Neo4j database (username: neo4j)"
  type        = string
  sensitive   = true
}

variable "volume_size" {
  description = "Size of the EBS root volume in GB"
  type        = number
  default     = 20
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "neo4j_cidr_blocks" {
  description = "CIDR blocks allowed for Neo4j access (ports 7474, 7687)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
