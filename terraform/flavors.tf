data "openstack_compute_flavor_v2" "tiny" {
    name = "ssc.tiny"
    vcpus = 1
    ram = 512
}

data "openstack_compute_flavor_v2" "small" {
    name = "ssc.small"
    vcpus = 1
    ram = 2048
}

data "openstack_compute_flavor_v2" "medium" {
    name = "ssc.medium"
    vcpus = 2
    ram = 4096
}

data "openstack_compute_flavor_v2" "medium_highcpu" {
    name = "ssc.medium.highcpu"
    vcpus = 4
    ram = 4096
}

data "openstack_compute_flavor_v2" "large" {
    name = "ssc.large"
    vcpus = 4
    ram = 8192
}
