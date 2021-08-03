resource "local_file" "inventory" {
  content = templatefile("inventory.tpl", {
    appserver = openstack_compute_instance_v2.appserver.network[0].fixed_ip_v4,
    gateway   = openstack_networking_floatingip_v2.public_ip.address,
  })
  filename = "../inventory"
}
