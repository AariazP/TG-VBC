terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "~> 0.2"
    }
  }
}

provider "virtualbox" {}

resource "virtualbox_vm" "k8s_nodes" {
  count = var.vm_count

  name  = "k8s-node-${count.index}"
  image = var.vm_image_path
  cpus  = var.cpus
  memory = var.memory

  network_adapter {
    type           = "hostonly"
    host_interface = var.hostonly_interface
  }

  network_adapter {
    type = "nat"
  }

  # Puedes usar guest_additions_mode = "disable" si tu imagen no los tiene
  guest_additions_mode = "disable"

  # Esperar a que la VM esté lista para conexión
  provisioner "remote-exec" {
    inline = ["echo 'VM is ready'"]
    connection {
      type     = "ssh"
      user     = "vagrant" # o el usuario de tu imagen
      password = "vagrant"
      host     = self.network_adapter.0.ipv4_address
      timeout  = "5m"
    }
  }
}

output "node_ips" {
  value = [
    for vm in virtualbox_vm.k8s_nodes : vm.network_adapter.0.ipv4_address
  ]
}