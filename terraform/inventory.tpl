all:
  hosts:
    gateway:
      ansible_host: ${gateway}
    appserver:
      ansible_host: ${appserver}
      ansible_ssh_common_args: '-o ProxyCommand="ssh -W %h:%p -q dev@${gateway}"'
