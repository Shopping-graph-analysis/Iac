# Security Group for Neo4j EC2 Instance
resource "aws_security_group" "neo4j" {
  name        = "${var.project_name}-neo4j-sg"
  description = "Security group for Neo4j graph database on EC2"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
    description = "SSH access"
  }

  # Neo4j Browser (HTTP)
  ingress {
    from_port   = 7474
    to_port     = 7474
    protocol    = "tcp"
    cidr_blocks = var.neo4j_cidr_blocks
    description = "Neo4j Browser HTTP"
  }

  # Neo4j Bolt Protocol
  ingress {
    from_port   = 7687
    to_port     = 7687
    protocol    = "tcp"
    cidr_blocks = var.neo4j_cidr_blocks
    description = "Neo4j Bolt Protocol"
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-neo4j-sg"
  }
}

# IAM Role for EC2 Instance
resource "aws_iam_role" "neo4j_ec2" {
  name = "${var.project_name}-neo4j-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-neo4j-ec2-role"
  }
}

# Attach CloudWatch policy for logging
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.neo4j_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "neo4j_ec2" {
  name = "${var.project_name}-neo4j-ec2-profile"
  role = aws_iam_role.neo4j_ec2.name
}

# EC2 Instance for Neo4j
resource "aws_instance" "neo4j" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.neo4j.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.neo4j_ec2.name

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              yum update -y
              
              # Install Java 17 (required for Neo4j)
              yum install -y java-17-amazon-corretto-headless
              
              # Add Neo4j repository
              rpm --import https://debian.neo4j.com/neotechnology.gpg.key
              cat <<REPO > /etc/yum.repos.d/neo4j.repo
              [neo4j]
              name=Neo4j RPM Repository
              baseurl=https://yum.neo4j.com/stable/5
              enabled=1
              gpgcheck=1
              REPO
              
              # Install Neo4j
              yum install -y neo4j-5.15.0
              
              # Configure Neo4j
              NEO4J_CONF="/etc/neo4j/neo4j.conf"
              
              # Set initial password
              neo4j-admin dbms set-initial-password '${var.neo4j_password}'
              
              # Configure Neo4j to listen on all interfaces
              echo "server.default_listen_address=0.0.0.0" >> $NEO4J_CONF
              echo "server.bolt.listen_address=:7687" >> $NEO4J_CONF
              echo "server.http.listen_address=:7474" >> $NEO4J_CONF
              
              # Enable remote connections
              echo "dbms.connector.bolt.enabled=true" >> $NEO4J_CONF
              echo "dbms.connector.http.enabled=true" >> $NEO4J_CONF
              
              # Set memory configuration (adjust based on instance type)
              echo "server.memory.heap.initial_size=512m" >> $NEO4J_CONF
              echo "server.memory.heap.max_size=1g" >> $NEO4J_CONF
              echo "server.memory.pagecache.size=512m" >> $NEO4J_CONF
              
              # Enable Neo4j service
              systemctl enable neo4j
              systemctl start neo4j
              
              # Wait for Neo4j to start
              sleep 30
              
              # Create completion marker
              echo "Neo4j installation completed at $(date)" > /var/log/neo4j-setup-complete.log
              EOF

  tags = {
    Name = "${var.project_name}-neo4j-instance"
  }

  lifecycle {
    create_before_destroy = true
  }
}
