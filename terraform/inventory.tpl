all:
  hosts:
    monitor:
      ansible_host: ${monitor}
    appserver:
      ansible_host: ${appserver}
      ansible_ssh_common_args: '-o ProxyCommand="ssh -W %h:%p -q dev@${monitor}"'
