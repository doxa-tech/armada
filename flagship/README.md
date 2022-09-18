# Setup

This guide explains how to setup the `Docker` nodes, enable the `Swarm` orchestrator, deploy the `Traefik` reverse proxy and the `Portainer` container manager.

## Nodes

You need at least one node, the `Swarm` manager, which hosts `Traefik` and `Portainer`. You can then add as many worker nodes as needed.

In your cloud provider, you need to add nodes which run the docker engine. The manager node must have a public IP address. Configure your domains to this IP address.

## Swarm

We will enable the docker `Swarm` mode to manage the cluster of nodes. On the manager node, run the command:

`docker swarm init --advertise-addr <NODE IP>`

This node is now a `Swarm` manager. If your cluster is in a private network, the advertised IP address is the private address of the node.

For each additional worker node, run the command:

`docker swarm join --token <MANAGER TOKEN> <MANAGER IP>:2377`

The token can be obtained at the initialization of the manager node or by running on the manager:

`docker swarm join-token worker`

Your cluster is now ready to orchestrate containers !

## Traefik/Portainer

Copy the `portainer.yml` file to the manager node.

First, create an empty file `acme.json`:

`touch acme.json`

Then, create two overlay networks:

`docker network create -d overlay agent_network`

`docker network create -d overlay public`

Finally, deploy the stack:

`docker stack deploy portainer -c portainer.yml`

You can now access Portainer through the domain specified in `portainer.yml`. You can view the state of the stack via `docker service ls`.

## Labelize nodes

On the manager, you can list the nodes:

`docker node ls`

To add a label, run

`docker node update --label-add key:value <NODE HOSTNAME>`

To display the node's labels:

`docker node inspect --format '{{ .Spec.Labels }}' <NODE HOSTNAME>`

In your docker compose, you can specify the deploy target using the labels:

```yaml
deploy:
  placement: 
      constraints: 
          - node.labels.key == value
```