# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Armada is an infrastructure-as-code monorepo that manages multiple web services across three projects using Docker Swarm orchestration on Infomaniak Cloud (OpenStack). It uses Terraform for provisioning, Ansible for configuration management, and Traefik as a reverse proxy with automatic TLS via Let's Encrypt.

## Repository Structure

```
infrastructure/       # Terraform IaC + Ansible playbooks + cloud-init scripts
flagship/             # Doxa Tech services (monitoring, wiki)
bullenetwork/         # Bulle Network services (static sites, Directus CMS, o2vie)
rencontredejeunesse/  # Rencontre de Jeunesse services (chatwoot, mattermost, rocketchat, zulip, static sites)
```

Each service directory contains a `docker-compose.yml` defining Docker Swarm stacks.

## Service Naming Convention

Services use a namespace prefix with underscore, followed by kebab-case name:
- `fs_` = Flagship (e.g., `fs_monitoring`)
- `bn_` = Bulle Network (e.g., `bn_directus`)
- `rj_` = Rencontre de Jeunesse (e.g., `rj_chatwoot`)

## Key Commands

### Terraform (infrastructure provisioning)
```bash
cd infrastructure
tofu init          # Initialize Terraform
tofu plan          # Preview changes
tofu apply         # Apply infrastructure changes
```

### Ansible (configuration management)
```bash
cd infrastructure/ansible
ansible-playbook init_swarm.yml              # Initialize Docker Swarm cluster
ansible-playbook create_postgres_user.yml    # Create database user for a service
ansible-playbook create_backup_task.yml      # Set up daily DB backups
ansible-playbook install_node_exporter.yml   # Install monitoring agent
ansible-playbook restore_postgres_dump.yml   # Restore database from dump
```

### Docker Swarm (service deployment)
```bash
docker stack deploy -c docker-compose.yml <stack_name>   # Deploy a service stack
```

## Architecture

**Cluster topology:**
- Manager/Proxy node: runs Traefik (reverse proxy) + Portainer (management UI)
- Worker nodes (2): run application services
- Database node: dedicated PostgreSQL server (static IP 192.168.10.100)

**Networking:** Internal swarm network on 192.168.10.0/24 with overlay networks `agent_network` and `public`. External access through a floating IP on the proxy node.

**Traefik routing:** All services are exposed via Traefik labels in their docker-compose files. TLS certificates are provisioned automatically via Let's Encrypt DNS challenge through Cloudflare.

**Secrets and configs:** Sensitive values use Docker secrets; service configurations (e.g., nginx configs) use Docker configs. Passwords and tokens are passed as environment variables.

## Infrastructure Details

- **Cloud provider:** Infomaniak Cloud (OpenStack), region dc4-a
- **OS:** Debian 12 Bookworm (cloud-init bootstrapped)
- **Monitoring:** Prometheus + Grafana + Node Exporter
- **Static site deployment:** Uses Hodor with webhook-triggered deployments
