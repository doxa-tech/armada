# Infrastructure

## Deploy

```
tofu apply
```

Update IP addresses in the `ssh_config`.

Wait ~1 minute for the instance to boot.

```
cd ansible
```

```
ssh-add ~/.ssh/armada_ed25519
```

```
ansible-playbook init_swarm.yml
```

```
ansible-playbook portainer.yml
```

