output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.neo4j.id
}

output "public_ip" {
  description = "Public IP address of the Neo4j instance"
  value       = aws_instance.neo4j.public_ip
}

output "private_ip" {
  description = "Private IP address of the Neo4j instance"
  value       = aws_instance.neo4j.private_ip
}

output "neo4j_browser_url" {
  description = "URL for Neo4j Browser interface"
  value       = "http://${aws_instance.neo4j.public_ip}:7474"
}

output "neo4j_bolt_url" {
  description = "Bolt protocol URL for Neo4j connections"
  value       = "bolt://${aws_instance.neo4j.public_ip}:7687"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.neo4j.id
}
