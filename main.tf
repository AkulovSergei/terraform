terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token = var.IAM_TOKEN
  cloud_id  = "b1g3a9ad3ktf3ktngcjv"
  folder_id = "b1gnqelhsinht34q3fgh"
  zone      = "ru-central1-a"
}

// Задаем переменную в которой будет хрониться IAM_TOKEN переданный через переменную окружения
variable "IAM_TOKEN" {
  type = string
  description = "Use export TF_VAR_IAM_TOKEN = your-iam-token in shell"
}

// Говорим Терраформу где искать образ для виртуальной машины
data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
}

// Создаем виртуальную машину из публичного образа ubuntu
resource "yandex_compute_instance" "netology" {
  name        = "netology-vm1"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      type = "network-hdd"
      size = 9
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_netology.id
    nat = true
  }
}

// Создаем частную сеть
resource "yandex_vpc_network" "network_netology" {
  name = "net_netology"
}

//Создаем частную подсеть
resource "yandex_vpc_subnet" "subnet_netology" {
  name           = "sub_netology"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_netology.id
  v4_cidr_blocks = ["10.128.0.0/24"]
}

// Выводим в output внешний ip-адрес созданной виртуальной машины
output "external_ip_addr" {
  value = yandex_compute_instance.netology.network_interface.0.nat_ip_address
}
