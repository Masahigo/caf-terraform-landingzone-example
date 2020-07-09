## define here the outputs you want to expose to higher level landing zone

output "prefix" {
  value       = local.prefix
  description = "prefix from level0"
}

output "environment" {
  value       = local.environment
  description = "environment from level0"
}