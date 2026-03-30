# Chỉ dùng public key có sẵn, không generate nữa
resource "aws_key_pair" "ehkey_pair_threetier" {
  key_name   = "ehkeypair"
  public_key = file("${path.module}/keypair/ehkey_pair.pub")

  lifecycle {
    ignore_changes  = [public_key]
  }
}

