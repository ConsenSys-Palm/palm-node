data "aws_secretsmanager_secret" "palm_ssh_secret" {
  name = "palm-keypair"
}

data "aws_secretsmanager_secret_version" "palm_ssh" {
  secret_id = data.aws_secretsmanager_secret.palm_ssh_secret.id
}