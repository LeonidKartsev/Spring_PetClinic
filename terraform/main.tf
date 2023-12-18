terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.92"
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_vpc_security_group" "project-sg" {
  name        = "project security group"
  description = "Description for security group"
  network_id  = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "Rule description for ssh connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Rule description for incoming traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Rule description for proxying"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}

resource "yandex_compute_instance" "vm" {
  name = "project"

  resources {
    cores  = 2
    memory = 6
  }

  boot_disk {
    initialize_params {
      image_id  = var.image_id
    }
  }

  network_interface {
    subnet_id      = var.subnet_id
    nat            = true
    nat_ip_address = var.nat_ip_address
  }

  metadata = {
    user-data = "ubuntu:${file("~/spring-petclinic_project/terraform/meta.txt")}"
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.nat_ip_address

  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install ca-certificates curl gnupg",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=\\\"$(dpkg --print-architecture)\\\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \\\"$(. /etc/os-release && echo \\\"$VERSION_CODENAME\\\")\\\" stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y",
      "sudo usermod -aG docker $USER",
      "git clone https://github.com/spring-projects/spring-petclinic.git",
      "cd ./spring-petclinic_project/spring-petclinic/",
      "sudo docker network create mysqlnet",
      "sudo docker compose -f docker-compose_app.yml up -d",
      "sudo apt-get install docker-compose -y"
    ]
  }
}
