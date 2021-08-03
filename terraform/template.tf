locals {
  hosts = toset(["gateway", "appserver"])
}

data "template_file" "cloud-template" {
  for_each = local.hosts

  template = file("${each.key}_data.tpl")
  vars = {
    public_key = file("~/.ssh/mfa_ed25519.pub")
  }
}

data "template_cloudinit_config" "cloud-config" {
  for_each = local.hosts

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloud-template[each.key].rendered
  }
}

resource "local_file" "inventory" {
  content = templatefile("inventory.tpl", {
    appserver = openstack_compute_instance_v2.appserver.network[0].fixed_ip_v4,
    gateway   = openstack_networking_floatingip_v2.public_ip.address,
  })
  filename = "../inventory"
}
