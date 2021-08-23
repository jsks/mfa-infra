resource "openstack_blockstorage_volume_v2" "db_vol" {
  name        = "db_vol"
  description = "Block storage for PostgreSQL"
  size        = 900
}

resource "openstack_compute_instance_v2" "appserver" {
  name            = "appserver"
  flavor_name     = "ssc.medium.highcpu"
  image_name      = "Debian 10 (Buster) - latest"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup.name}"]
  user_data       = data.template_cloudinit_config.cloud-config["appserver"].rendered
  network {
    name = var.network_name
  }
  lifecycle {
    ignore_changes = [image_name, user_data]
  }
}

resource "openstack_compute_volume_attach_v2" "attach_vol" {
  instance_id = openstack_compute_instance_v2.appserver.id
  volume_id   = openstack_blockstorage_volume_v2.db_vol.id
  device      = "/dev/vdb"
}

output "private_ip" {
  value = openstack_compute_instance_v2.appserver.network[0].fixed_ip_v4
}
