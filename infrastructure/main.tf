provider "openstack" {
  auth_url    = var.auth_url
  tenant_name = var.project_name
  user_name   = var.username
  password    = var.password
  region      = var.region
}

# external network for floating ip
data "openstack_networking_network_v2" "external_network" {
  name = var.external_network
}

# network of swarm cluster (workers)
resource "openstack_networking_network_v2" "swarm" {
  name = "swarm-net"
}

resource "openstack_networking_subnet_v2" "swarm_subnet" {
  name            = "swarm-subnet"
  network_id      = openstack_networking_network_v2.swarm.id
  cidr            = "192.168.10.0/24"
  ip_version      = 4
}

# router to connect swarm to public network
# instances in swarm can get a public ip (e.g. proxy)
resource "openstack_networking_router_v2" "public_router" {
  name                = "public-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external_network.id
}

resource "openstack_networking_router_interface_v2" "public_router_swarm" {
  router_id = openstack_networking_router_v2.public_router.id
  subnet_id = openstack_networking_subnet_v2.swarm_subnet.id
}

# port to attach proxy to swarm network
resource "openstack_networking_port_v2" "proxy_port" {
  name           = "proxy-port"
  network_id     = openstack_networking_network_v2.swarm.id
  security_group_ids = [
    openstack_networking_secgroup_v2.sg_proxy.id,
    openstack_networking_secgroup_v2.sg_swarm.id
  ]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.swarm_subnet.id
  }
}

# attach a floating ip to proxy (public ip)
resource "openstack_networking_floatingip_v2" "proxy_ip" {
  pool = var.external_network
}

resource "openstack_networking_floatingip_associate_v2" "proxy_ip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.proxy_ip.address
  port_id     = openstack_networking_port_v2.proxy_port.id
}

# key pair to access proxy
resource "openstack_compute_keypair_v2" "armada_keypair" {
  name       = "armada-keypair"
  public_key = file("~/.ssh/armada_ed25519.pub")
}

# create proxy instance
resource "openstack_compute_instance_v2" "proxy" {
  name            = "proxy"
  flavor_name     = "a1-ram2-disk20-perf1"
  image_name      = "Debian 12 bookworm"
  key_pair        = openstack_compute_keypair_v2.armada_keypair.name

  network {
    port = openstack_networking_port_v2.proxy_port.id
  }

  user_data = file("./cloud-init/docker.yml")
}

# create a volume for the proxy
resource "openstack_blockstorage_volume_v3" "proxy_volume" {
  name = "proxy-volume"
  size = 10
}

resource "openstack_compute_volume_attach_v2" "attach_proxy_volume" {
  instance_id = openstack_compute_instance_v2.proxy.id
  volume_id   = openstack_blockstorage_volume_v3.proxy_volume.id
}

# create worker node instance
resource "openstack_compute_instance_v2" "workers" {
  count           = var.number_of_workers
  name            = "worker-${count.index + 1}"
  flavor_name     = "a1-ram2-disk20-perf1"
  security_groups = ["sg-swarm"]
  image_name      = "Debian 12 bookworm"
  key_pair        = openstack_compute_keypair_v2.armada_keypair.name

  network {
    uuid = openstack_networking_network_v2.swarm.id
  }

  user_data = file("./cloud-init/docker.yml")
}

# create a volume for each worker
resource "openstack_blockstorage_volume_v3" "worker_volumes" {
  count = var.number_of_workers
  name  = "worker-volume-${count.index + 1}"
  size  = 10
}

resource "openstack_compute_volume_attach_v2" "attach_worker_volumes" {
  count       = var.number_of_workers
  instance_id = openstack_compute_instance_v2.workers[count.index].id
  volume_id   = openstack_blockstorage_volume_v3.worker_volumes[count.index].id
}

# create database instance
resource "openstack_compute_instance_v2" "database" {
  name            = "database"
  flavor_name     = "a1-ram2-disk20-perf1"
  security_groups = ["sg-database"]
  image_name      = "Debian 12 bookworm"
  key_pair        = openstack_compute_keypair_v2.armada_keypair.name

  network {
    port = openstack_networking_port_v2.database_port.id
  }

  user_data = file("./cloud-init/postgres.yml")
}

resource "openstack_blockstorage_volume_v3" "database_volume" {
  name = "database-volume"
  size = 10
}

resource "openstack_compute_volume_attach_v2" "attach_database_volume" {
  instance_id = openstack_compute_instance_v2.database.id
  volume_id   = openstack_blockstorage_volume_v3.database_volume.id
}

resource "openstack_networking_port_v2" "database_port" {
  name       = "database-port"
  network_id = openstack_networking_network_v2.swarm.id
  security_group_ids = [
    openstack_networking_secgroup_v2.sg_database.id,
  ]

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.swarm_subnet.id
    ip_address = "192.168.10.100"
  }
}