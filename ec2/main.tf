data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

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

  ssh_cidr_blocks   = ["0.0.0.0/0"]
  neo4j_cidr_blocks = ["0.0.0.0/0"]
}
