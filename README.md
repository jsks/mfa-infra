MFA Infrastructure
---

Orchestration code for MFA twitter scraping project.

### Requirements

Resource creation is handled by `terraform` while configuration
management is done with `ansible`. Before getting started the
following steps are necessary.

#### SSH Keys

Password login is disabled on all hosts. Create a SSH key pair, which
will later be automatically injected into the new hosts. This can't be
done with terraform since the private key will be stored unencrypted.

```sh
# Note: this filename is hardcoded in later scripts
$ ssh-keygen -t ed25519 -f ~/.ssh/mfa_ed25519
```

#### Password Management

`pass(1)` is used as a vault for all secrets. If just getting started,
create a gpg key and initialize the password store.

```sh
$ gpg --full-key-gen
$ pass init <id | email>
```

For full deployment, the following secrets are required:

```sh
$ pass show dev/mfa
dev/mfa
├── gh-access-token    # GitHub access token from jsks/mfa-twitter
├── gh-webhook-secret  # Webhook secret for notifications from jsks/mfa-twitter
├── twitter-token      # Token for Twitter API
├── wg-client          # Wireguard client credentials
└── wg-server          # Wireguard server credentials
```

The latter two for the Wireguard VPN can be created using the
convenience script `scripts/wg_keys.sh`, which will generate all
necessary keys and automatically insert them into the vault.

Finally, ansible will also automatically generate credentials for
Postgres and store them as `dev/mfa/postgres`.

### Resource Creation

All resources are hosted on Openstack. Before running `terraform`,
generate application credentials from the Openstack instance and
export them in the current shell.

```sh
$ source <openstack-credentials.sh>
```

Then, initialize `terraform` and apply all changes.

```sh
$ cd terraform
$ terraform init
$ terraform apply
```

### Config Management

To provision the newly created servers run the `site.yml`
playbook. This requires first installing the `community.postresql`
collection.

```sh
$ ansible-galaxy collection install community.postgresql
$ ansible-playbook site.yml
```

### Post-Creation

Two servers will have been created, `gateway` and `appserver`. Only
the former is publically accessible, while the latter runs PostgreSQL
and the [mfa-twitter](https://github.com/jsks/mfa-twitter) scraper
(for deployment see the linked repository).

The locally generated `client-wg0.conf` file holds the wireguard
configuration for connecting to the `gateway` VPN. Simply insert the
client private key from the vault, `pass show dev/mfa/wg-client`, and
copy the config file to `/etc/wireguard`.
