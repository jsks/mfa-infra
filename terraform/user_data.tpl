#cloud-config

%{if host == "appserver"}
fs_setup:
  - label: DATA
    filesystem: ext4
    device: /dev/vdb
    partition: auto

mounts:
  - [ /dev/vdb, /mnt, auto, "defaults,noexec" ]
%{endif}

locale: en_US.UTF-8

package_reboot_if_required: true
package_update: true
package_upgrade: true
packages:
  - ansible

%{if host == "appserver"}
fqdn: appserver.intranet
%{else}
manage_etc_hosts: false
hostname: gateway
runcmd:
  - "sed -i 's/debian.example.com/gateway.intranet gateway/' /etc/hosts"
%{endif}

users:
  - name: dev
    lock-passwd: true
    groups: [ adm, netdev, sudo ]
    sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
    shell: /bin/bash
    ssh_authorized_keys:
      - ${public_key}
