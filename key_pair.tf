# Create key pair
resource "aws_key_pair" "main" {
  key_name   = "${var.project}-key"
  public_key = "${file("${var.project}-key.pub")}"
}
