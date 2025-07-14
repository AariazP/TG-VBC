packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "iso_path" {
  type    = string
  default = "./debian-12.11.0-amd64-netinst.iso"
}

source "virtualbox-iso" "debian-amd64" {
  iso_url            = var.iso_path
  iso_checksum       = "none"
  ssh_username       = "root"
  ssh_password       = "debian"
  shutdown_command   = "echo 'debian' | sudo -S shutdown -P now"

  guest_os_type      = "Debian_64"
  vm_name            = "k8s-debian-amd64"
  headless           = true
  disk_size          = 12288
  cpus               = 2
  memory             = 2048

  boot_wait = "30s"
  ssh_timeout         = "60m"
  ssh_wait_timeout    = "60m"
  ssh_handshake_attempts = 100

  boot_command = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "debian-installer/locale=en_US ",
    "console-setup/ask_detect=false ",
    "console-setup/layoutcode=us ",
    "keyboard-configuration/layout=USA ",
    "netcfg/get_hostname=debian ",
    "netcfg/get_domain=local ",
    "<enter>"
  ]

  http_directory = "./"
}

build {
  name    = "k8s-debian-amd64"
  sources = ["source.virtualbox-iso.debian-amd64"]

  provisioner "shell" {
    script = "scripts/install-k8s.sh"
  }
}
