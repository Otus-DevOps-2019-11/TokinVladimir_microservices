variable public_key_path {
  description = "Path to the public key used to connect to instance"
}
variable zone {
  description = "Zone"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-docker-host"
}

variable provision_enabled {
  default = "false"
}

variable install_app {
  default = false
}
variable private_key {
  description = "Path to the private key used for ssh access"
}

variable instance_count {
  default = "1"
}
