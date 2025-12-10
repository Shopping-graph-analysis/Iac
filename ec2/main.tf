# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Deploy Neo4j on EC2
module "neo4j" {
  source = "../modules/ec2"

  project_name   = "shopping-graph"
  instance_type  = "t3.medium"
  ami_id         = data.aws_ami.amazon_linux_2023.id
  vpc_id         = data.aws_vpc.default.id
  subnet_id      = data.aws_subnets.default.ids[0]
  key_name       = var.key_name
  neo4j_password = var.neo4j_password
  volume_size    = 30

  # Security: Restrict access in production
  ssh_cidr_blocks   = ["0.0.0.0/0"] # Change to your IP for production
  neo4j_cidr_blocks = ["0.0.0.0/0"] # Change to your VPC CIDR for production
}

# Outputs
output "neo4j_instance_id" {
  description = "EC2 instance ID running Neo4j"
  value       = module.neo4j.instance_id
}

output "neo4j_public_ip" {
  description = "Public IP address of Neo4j instance"
  value       = module.neo4j.public_ip
}

output "neo4j_browser_url" {
  description = "URL to access Neo4j Browser"
  value       = module.neo4j.neo4j_browser_url
}

output "neo4j_bolt_url" {
  description = "Bolt connection URL for applications"
  value       = module.neo4j.neo4j_bolt_url
}

output "connection_instructions" {
  description = "Instructions to connect to Neo4j"
  value       = <<-EOT
    Neo4j Browser: ${module.neo4j.neo4j_browser_url}
    Username: neo4j
    Password: [the password you set in variables]
    
    Bolt URL for applications: ${module.neo4j.neo4j_bolt_url}
    
    SSH Access: ssh -i your-key.pem ec2-user@${module.neo4j.public_ip}
  EOT
}
