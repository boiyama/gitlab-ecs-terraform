# Get user data
data "template_file" "bastion_user_data" {
  template = "${file("${path.module}/templates/bastion/user_data.sh")}"

  vars {
    efs_id = "${aws_efs_file_system.main.id}"
  }
}

# Create bastion instance
resource "aws_instance" "bastion" {
  instance_type          = "t2.nano"
  ami                    = "${data.aws_ami.amazon.id}"
  user_data              = "${data.template_file.bastion_user_data.rendered}"
  key_name               = "${aws_key_pair.main.key_name}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  subnet_id              = "${aws_subnet.public.0.id}"

  tags {
    Name = "${var.project}-instance-bastion"
  }
}
