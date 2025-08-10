output "worker_ips" {
  value = openstack_compute_instance_v2.workers[*].access_ip_v4
}

output "proxy_ip" {
  value = openstack_networking_floatingip_v2.proxy_ip.address
}

output "database_ip" {
  value = openstack_compute_instance_v2.database.access_ip_v4
}