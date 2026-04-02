resource "tls_private_key" "ehkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ehkey_pair_threetier" {
  key_name   = "ehkey_pair_threetier"
  public_key = tls_private_key.ehkey.public_key_openssh
}

output "private_key_pem" {
  value     = tls_private_key.ehkey.private_key_pem
  sensitive = true
}