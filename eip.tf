# Create EIPs for NAT
resource "aws_eip" "nat" {
  count = length(aws_subnet.public.*.id)
  vpc   = true
}

# Create EIP for bastion
resource "aws_eip" "bastion" {
  vpc      = true
  instance = aws_instance.bastion.id
}
