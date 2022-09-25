# Naming convention

Use "dash" (kebab-case) for multiple-words, and underscore for name spaces.

For example, a service is named "static-websites", and if it needs to be
prefixed by a namespace, it will be prefixed with an underscore, e.g.
"bn_static-websites".

# Deploy locally a single node for testing purposes

```sh
# initialize a swarm
docker swarm init
# check the swarm
docker info
docker node ls
# create the public network
docker network create --scope swarm public
# create a config, if needed
docker config create my_config config.json
# add label
docker node update --label-add project=bullenetwork my_service
# deploy the stack
docker stack deploy --compose-file docker-compose.yml my_stack_name
# check the services
docker service ls
# check one particular service
docker service ps my_service
# check the logs on a container
docker service logs my_container
# remove the stack
docker stack rm my_stack_name