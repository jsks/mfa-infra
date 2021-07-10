resource "openstack_compute_instance_v2" "monitor" {
  name            = "monitor"
  flavor_id       = data.openstack_compute_flavor_v2.small.id
  image_name      = "Debian 10 (Buster) - latest"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup.name}"]
  user_data       = file("./user_data.yaml")
  network {
    name = "SNIC 2021/18-3 Internal IPv4 Network"
  }
}

resource "openstack_compute_floatingip_associate_v2" "attach_ip" {
  floating_ip = openstack_networking_floatingip_v2.public_ip.address
  instance_id = openstack_compute_instance_v2.monitor.id
}

output "float_ip" {
  value = openstack_networking_floatingip_v2.public_ip.address
}


