output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_capacity_provider_name" {
  value = aws_ecs_capacity_provider.ecs_cluster.name
}
