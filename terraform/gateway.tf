resource "openstack_compute_instance_v2" "gateway" {
  name            = "gateway"
  flavor_name     = "ssc.tiny"
  image_name      = "Debian 10 (Buster) - latest"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup.name}"]
  user_data       = file("./gateway_data.yaml")
  network {
    name = var.network_name
  }
}

resource "openstack_compute_floatingip_associate_v2" "attach_ip" {
  floating_ip = openstack_networking_floatingip_v2.public_ip.address
  instance_id = openstack_compute_instance_v2.gateway.id
}

output "float_ip" {
  value = openstack_networking_floatingip_v2.public_ip.address
}
