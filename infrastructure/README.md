# Infrastructure

## Prerequisites

Install Ansible community playbooks

```
ansible-galaxy collection install prometheus.prometheus
```

If you run the playbooks from MacOS

```
brew install gnu-tar
```

## Deploy

To deploy or update the infrastructure. You need the password to connect to OpenStack. You confirm the changes before applying them.

```
tofu apply
```

Update IP addresses in the `ansible/ssh_config` with the output of the deployment.

Wait ~1 minute for the instance to boot. You can then run the Ansible playbooks.

Add the authentication key to your agent. The key is protected by a passphrase.
```
ssh-add ~/.ssh/armada_ed25519
```

The playbooks are located in the `ansible` folder.
```
cd ansible
```

Initialize Docker Swarm, setting up managers and workers defined in the inventory (`inventory.ini`).
```
ansible-playbook init_swarm.yml
```

Install Portainer with the stack defined in `flagship/portainer.yml.j2`.
```
ansible-playbook portainer.yml
```

Install Node exporter on each instance. The service exports metrics to monitor usage (CPU, memory, ...)
```
ansible-playbook install_node_exporter.yml
```

To connect to a service via SSH
```
ssh -F ssh-config <hostname>
```

## Database

Setup a backup script in cron. The task dumps the database every day and keeps the last 30 days.
```
ansible-playbook create_backup_task.yml
```

Create a new user and a database for a new service
```
ansible-playbook create_postgres_user.yml
```

Restore a `.sql` dump
```
ansible-playbook restore_postgres_dump.yml
```

