output "efs-mount-target-dns" {
  description = "Address of the mount target provisioned."
  value       = "${aws_efs_mount_target.main.0.dns_name}"
}
