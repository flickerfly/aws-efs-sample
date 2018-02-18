# Create a security group that will allow us to both
# SSH into the instance as well as access prometheus
# publicly (note.: you'd not do this in prod - otherwise
# you'd have prometheus publicly exposed).
resource "aws_security_group" "allow-ssh-and-egress" {
  name = "allow-ssh-and-eggress"

  description = "Allows SSH traffic into instances as well as all eggress."
  vpc_id      = "${module.networking.vpc-id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_ssh-all"
  }
}

# Create an EC2 instance that will interact with an EFS
# filesystem that is mounted in out specific availability
# zone.
resource "aws_instance" "inst1" {
  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     = "t2.micro"
  key_name          = "${aws_key_pair.main.key_name}"
  availability_zone = "sa-east-1a"
  subnet_id         = "${module.az-subnet-id-mapping["sa-east-1a"]}"

  vpc_security_group_ids = [
    "${aws_security_group.allow-ssh-and-egress.id}",
  ]

  tags {
    Name = "inst1"
  }
}

resource "aws_instance" "inst2" {
  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     = "t2.micro"
  key_name          = "${aws_key_pair.main.key_name}"
  availability_zone = "sa-east-1b"
  subnet_id         = "${module.az-subnet-id-mapping["sa-east-1b"]}"

  vpc_security_group_ids = [
    "${aws_security_group.allow-ssh-and-egress.id}",
  ]

  tags {
    Name = "inst1"
  }
}
