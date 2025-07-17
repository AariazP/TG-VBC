variable "vm_image_path" {
  description = "Ruta a la imagen OVF generada por Packer"
  type        = string
}

variable "hostonly_interface" {
  description = "Nombre de la interfaz de red Host-Only de VirtualBox"
  type        = string
  default     = "vboxnet0"
}

variable "cpus" {
  default = 2
}

variable "memory" {
  default = 2048
}

variable "vm_count" {
  default = 2
}