terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone  = "ru-central1-a"
  token = var.token
  folder_id = var.folder_id
  cloud_id = var.cloud_id
}

locals {
  vpc_name     = "${var.env_name}-${var.vpc_name}"
  cluster_name = "${var.cluster_name}-${var.env_name}"
  folder_id    = var.folder_id
}

## Определение AWS VPC
resource "yandex_vpc_network" "main" {
  name        = local.vpc_name
  description = "network for vpc"
  labels = {
    "name"                                        = local.vpc_name
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
  }
  folder_id = local.folder_id
}

# Определение подсети

resource "yandex_vpc_subnet" "public-subnet-a" {
  folder_id      = local.folder_id
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_a_cidr]
  zone           = "ru-central1-a"
  route_table_id = yandex_vpc_route_table.rt.id

  labels = {
    "name" = (
    "${local.vpc_name}-public-subnet-a"
    )
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

resource "yandex_vpc_subnet" "public-subnet-b" {
  folder_id      = local.folder_id
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_b_cidr]
  zone           = "ru-central1-b"
  route_table_id = yandex_vpc_route_table.rt.id

  labels = {
    "name" = (
    "${local.vpc_name}-public-subnet-b"
    )
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

resource "yandex_vpc_subnet" "private-subnet-a" {
  folder_id      = local.folder_id
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_a_cidr]
  zone           = "ru-central1-a"
  route_table_id = yandex_vpc_route_table.rt.id

  labels = {
    "name" = (
    "${local.vpc_name}-private-subnet-a"
    )
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/inetrnal-elb"             = "1"
  }
}

resource "yandex_vpc_subnet" "private-subnet-b" {
  folder_id      = local.folder_id
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_b_cidr]
  zone           = "ru-central1-b"
  route_table_id = yandex_vpc_route_table.rt.id

  labels = {
    "name" = (
    "${local.vpc_name}-private-subnet-b"
    )
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/inetrnal-elb"             = "1"
  }
}

# Интернет шлюх и таблицы маршрутизации для общедоступных подсетей подсетей
resource "yandex_vpc_gateway" "ygw" {
  folder_id = local.folder_id
  labels = {
    name = "${local.vpc_name}-igw"
  }
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  folder_id  = local.folder_id
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.ygw.id
  }

  labels = {
    "name" = "${local.vpc_name}-public-route"
  }
}


