

#
# Proxy security group
#

resource "openstack_networking_secgroup_v2" "sg_proxy" {
  name        = "sg-proxy"
  description = "Public-facing proxy node security group"
}

resource "openstack_networking_secgroup_rule_v2" "sg_proxy_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.sg_proxy.id
}

resource "openstack_networking_secgroup_rule_v2" "sg_proxy_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = openstack_networking_secgroup_v2.sg_proxy.id
}

resource "openstack_networking_secgroup_rule_v2" "sg_proxy_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.sg_proxy.id
}

resource "openstack_networking_secgroup_rule_v2" "sg_proxy_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.sg_proxy.id
}

# Node exporter
resource "openstack_networking_secgroup_rule_v2" "sg_proxy_node_exporter" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9100
  port_range_max    = 9100
  remote_ip_prefix  = "192.168.10.0/24"
  security_group_id = openstack_networking_secgroup_v2.sg_proxy.id
}

#
# Swarm security group
#

resource "openstack_networking_secgroup_v2" "sg_swarm" {
  name        = "sg-swarm"
  description = "Internal swarm nodes security group"
}

# SSH
resource "openstack_networking_secgroup_rule_v2" "sg_swarm_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.sg_swarm.id
}

# Swarm control traffic
resource "openstack_networking_secgroup_rule_v2" "sg_swarm_control" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2377
  port_range_max    = 2377
  remote_group_id   = openstack_networking_secgroup_v2.sg_swarm.id
  security_group_id = openstack_networking_secgroup_v2.sg_swarm.id
}

# Swarm TCP
resource "openstack_networking_secgroup_rule_v2" "sg_swarm_discovery_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 7946
  port_range_max    = 7946
  remote_group_id   = openstack_networking_secgroup_v2.sg_swarm.id
  security_group_id = openstack_networking_secgroup_v2.sg_swarm.id
}

# Swarm gossip UDP
resource "openstack_networking_secgroup_rule_v2" "sg_swarm_discovery_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 7946
  port_range_max    = 7946
  remote_group_id   = openstack_networking_secgroup_v2.sg_swarm.id
  security_group_id = openstack_networking_secgroup_v2.sg_swarm.id
}

# Overlay network
resource "openstack_networking_secgroup_rule_v2" "sg_swarm_overlay" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 4789
  port_range_max    = 4789
  remote_group_id   = openstack_networking_secgroup_v2.sg_swarm.id
  security_group_id = openstack_networking_secgroup_v2.sg_swarm.id
}

# Node exporter
resource "openstack_networking_secgroup_rule_v2" "sg_swarm_node_exporter" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9100
  port_range_max    = 9100
  remote_ip_prefix  = "192.168.10.0/24"
  security_group_id = openstack_networking_secgroup_v2.sg_swarm.id
}

#
# Database security group
#
resource "openstack_networking_secgroup_v2" "sg_database" {
  name        = "sg-database"
  description = "Database security group"
}

# PostgreSQL from swarm
resource "openstack_networking_secgroup_rule_v2" "sg_database_connection" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_group_id   = openstack_networking_secgroup_v2.sg_swarm.id
  security_group_id = openstack_networking_secgroup_v2.sg_database.id
}

# SSH
resource "openstack_networking_secgroup_rule_v2" "sg_database_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.sg_database.id
}

# Node exporter
resource "openstack_networking_secgroup_rule_v2" "sg_database_node_exporter" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9100
  port_range_max    = 9100
  remote_ip_prefix  = "192.168.10.0/24"
  security_group_id = openstack_networking_secgroup_v2.sg_database.id
}
