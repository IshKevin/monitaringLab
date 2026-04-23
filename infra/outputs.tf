output "jenkins_ip" {
  value = module.jenkins.public_ip
}

output "app_ip" {
  value = module.app.public_ip
}