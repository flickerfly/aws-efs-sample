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

module "networking" {
  source = "./networking"
  cidr   = "10.0.0.0/16"

  "az-subnet-mapping" = [
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

module "efs" {
  name    = "shared-fs"
  subnets = "${values(module.networking.az-subnet-id-mapping)}"
  vpc-id  = "${module.networking.vpc-id}"
}
