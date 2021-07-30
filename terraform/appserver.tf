resource "openstack_blockstorage_volume_v2" "db_vol" {
  name        = "db_vol"
  description = "Block storage for PostgreSQL"
  size        = 500
}

resource "openstack_compute_instance_v2" "app_server" {
  name            = "app-server"
  flavor_name     = "ssc.medium.highcpu"
  image_name      = "Debian 10 (Buster) - latest"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup.name}"]
  user_data       = file("./appserver_data.yaml")
  network {
    name = "SNIC 2021/18-3 Internal IPv4 Network"
  }
}

resource "openstack_compute_volume_attach_v2" "attach_vol" {
  instance_id = openstack_compute_instance_v2.app_server.id
  volume_id   = openstack_blockstorage_volume_v2.db_vol.id
  device      = "/dev/vdb"
}

output "private_ip" {
  value = openstack_compute_instance_v2.app_server.network[0].fixed_ip_v4
}
