#cloud-config

locale: en_US.UTF-8

package_update: true
package_upgrade: true
package_reboot_if_required: true
packages:
  - ansible

manage_etc_hosts: false
hostname: gateway
runcmd:
  - "echo 127.0.0.1 gateway.intranet gateway >> /etc/hosts"

users:
  - name: dev
    lock-passwd: true
    groups: [ adm, netdev, sudo ]
    sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
    shell: /bin/bash
    ssh_authorized_keys:
      - ${public_key}
