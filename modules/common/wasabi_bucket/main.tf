variable "name" {}
variable "region" {
  default = "eu-west-2"
}
variable "public_read_only" {
  default = false
}

resource "null_resource" "create_bucket" {
  triggers = {
    command = <<-EOF
      python3 create_bucket.py ${var.name} ${var.region} ${var.public_read_only}
    EOF
    md5 = filemd5("${path.module}/create_bucket.py")
  }
  provisioner "local-exec" {
    command = <<-EOF
      cd ${path.module}
      ${self.triggers.command}
    EOF
  }
}
