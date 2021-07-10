MFA Infrastructure
---

Provisioning code for MFA twitter scraping project.

### Terraform

```sh
$ cd terraform
$ source <openstack-credentials.sh>
$ terraform init
$ terraform apply
```

### Ansible

```sh
$ ansible-galaxy collection install community.postgresql
$ ansible-playbook site.yml
```
