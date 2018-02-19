variable "region" {
  description = "name of the region to put our resources - must have EFS"
  default     = "us-east-1"
}

variable "profile" {
  description = "name of the profile able to provision aws resources"
  default     = "beld"
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

variable "az-subnet-mapping" {
  type = "list"

  default = [
    {
      name = "us-east-1a"
      az   = "us-east-1a"
      cidr = "10.0.0.0/24"
    },
    {
      name = "us-east-1b"
      az   = "us-east-1b"
      cidr = "10.0.1.0/24"
    },
  ]
}

module "networking" {
  source = "github.com/cirocosta/sample-aws-networking//networking"
  cidr   = "10.0.0.0/16"

  "az-subnet-mapping" = "${var.az-subnet-mapping}"
}

module "efs" {
  source = "./efs"

  name          = "shared-fs"
  subnets-count = "${length(var.az-subnet-mapping)}"
  subnets       = "${values(module.networking.az-subnet-id-mapping)}"
  vpc-id        = "${module.networking.vpc-id}"
}

# Create an EC2 instance that will interact with an EFS
# filesystem that is mounted in out specific availability
# zone.
resource "aws_instance" "inst1" {
  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     = "t2.micro"
  key_name          = "${aws_key_pair.main.key_name}"
  availability_zone = "us-east-1a"
  subnet_id         = "${module.networking.az-subnet-id-mapping["us-east-1a"]}"

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
  availability_zone = "us-east-1b"
  subnet_id         = "${module.networking.az-subnet-id-mapping["us-east-1b"]}"

  vpc_security_group_ids = [
    "${aws_security_group.allow-ssh-and-egress.id}",
  ]

  tags {
    Name = "inst2"
  }
}
