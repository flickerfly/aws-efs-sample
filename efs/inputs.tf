variable "name" {
  type        = "string"
  description = "name of the filesystem"
}

variable "subnets" {
  type        = "list"
  description = "list of subnets to mount the fs to"
}

variable "subnets-count" {
  type        = "string"
  description = "number of subnets to mount to"
}

variable "vpc-id" {
  type        = "string"
  description = "id of the vpc where the subnets and the fs should live"
}
