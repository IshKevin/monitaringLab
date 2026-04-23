output "app_ip" {
  value = module.app.public_ip
}

output "monitoring_ip" {
  value = module.monitoring.public_ip
}