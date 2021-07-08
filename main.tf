terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

data "openstack_compute_flavor_v2" "tiny" {
  vcpus = 1
  ram   = 512
}

resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "SecurityLake"
  description = "Security group"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_floatingip_v2" "public_ip" {
  pool = "Public External IPv4 Network"
}

resource "openstack_blockstorage_volume_v2" "db_vol" {
  name        = "db_vol"
  description = "Block storage for PostgreSQL"
  size        = 10
}

resource "openstack_compute_instance_v2" "app_server" {
  name            = "app-server"
  flavor_id       = data.openstack_compute_flavor_v2.tiny.id
  image_name      = "Debian 10 (Buster) - latest"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup.name}"]
  user_data       = file("./user_data.yaml")
  network {
    name = "SNIC 2021/18-3 Internal IPv4 Network"
  }
}

resource "openstack_compute_volume_attach_v2" "attach_vol" {
  instance_id = openstack_compute_instance_v2.app_server.id
  volume_id   = openstack_blockstorage_volume_v2.db_vol.id
  device      = "/dev/vdb"
}

resource "openstack_compute_floatingip_associate_v2" "attach_ip" {
  floating_ip = openstack_networking_floatingip_v2.public_ip.address
  instance_id = openstack_compute_instance_v2.app_server.id
}

output "float_ip" {
  value = openstack_networking_floatingip_v2.public_ip.address
}
