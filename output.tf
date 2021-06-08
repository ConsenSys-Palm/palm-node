output "uat_public_ip" {
  value = module.palmnode_uat.public_ips
}

output "validator_public_ip" {
  value = module.palmnode_validator.public_ips
}
