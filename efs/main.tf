# Gathers information about the VPC that was provided
# such that we can know what CIDR block to allow requests
# from and to the FS.
data "aws_vpc" "main" {
  id = "${var.vpc-id}"
}

# Creates a new empty file system in EFS.
#
# Although we're not specifying a VPC_ID here, we can't have
# a EFS assigned to subnets in multiple VPCs.
#
# If we wanted to mount in a differente VPC we'd need to first
# remove all the mount points in subnets of one VPC and only 
# then create the new mountpoints in the other VPC.
resource "aws_efs_file_system" "main" {
  tags {
    Name = "${var.name}"
  }
}

# Creates a mount target of EFS in a specified subnet
# such that our instances can connect to it.
resource "aws_efs_mount_target" "main" {
  count = "${var.subnets-count}"

  file_system_id = "${aws_efs_file_system.main.id}"
  subnet_id      = "${element(var.subnets, count.index)}"

  security_groups = [
    "${aws_security_group.efs.id}",
  ]
}

# Allow both ingress and egress for port 2049 (NFS)
# such that our instances are able to get to the mount
# target in the AZ.
#
# Additionaly, we set the `cidr_blocks` that are allowed
# such that we restrict the traffic to machines that are
# within the VPC (and not outside).
resource "aws_security_group" "efs" {
  name        = "efs-mnt"
  description = "Allows NFS traffic from instances within the VPC."
  vpc_id      = "${var.vpc-id}"

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "${data.aws_vpc.main.cidr_block}",
    ]
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "${data.aws_vpc.main.cidr_block}",
    ]
  }

  tags {
    Name = "allow_nfs-ec2"
  }
}
