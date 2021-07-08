packer {
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "os_username" {
  type = string
  default = "ansible"
  sensitive = true
}

variable "os_password" {
  type = string
  default = "ansible"
  sensitive = true
}

locals {
  hashed_os_password = bcrypt("${var.os_password}")
}

source "virtualbox-iso" "ubuntu-21-04-live-server" {
  boot_command =           [
    "<esc><esc><esc><esc>e<wait>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>",
    "<enter><f10><wait>"
  ]
  boot_wait              = "5s"
  guest_os_type          = "ubuntu-64"
  http_content           = {
    "/meta-data" = file("subiquity/http/meta-data")
    "/user-data" = templatefile("subiquity/http/user-data.yaml.pkrtpl.hcl", {
      "os_username": "${var.os_username}"
      "hashed_os_password": "${local.hashed_os_password}"
    })
  }
  iso_url                = "https://releases.ubuntu.com/21.04/ubuntu-21.04-live-server-amd64.iso"
  iso_checksum           = "sha256:e4089c47104375b59951bad6c7b3ee5d9f6d80bfac4597e43a716bb8f5c1f3b0"
  memory                 = 1024
  output_directory       = "output/ubuntu-2104-live-server-ansible"
  shutdown_command       = "sudo shutdown -P now"
  ssh_handshake_attempts = "20"
  ssh_pty                = true
  ssh_timeout            = "20m"
  ssh_username           = "${var.os_username}"
  ssh_password           = "${var.os_password}"
}

build {
  sources = ["sources.virtualbox-iso.ubuntu-21-04-live-server"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
    ]
  }

  post-processor "vagrant" {
    output = "output/ubuntu-2104-live-server-ansible.box"
  }
}

