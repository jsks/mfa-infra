#cloud-config

locale: en_US.UTF-8

package_reboot_if_required: true
package_update: true
package_upgrade: true
packages:
  - ansible

manage_etc_hosts: false
fqdn: gateway.intranet
hostname: gateway.intranet

users:
  - name: dev
    lock-passwd: true
    groups: [ adm, netdev, sudo ]
    sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
    shell: /bin/bash
    ssh_authorized_keys:
      - ${public_key}
