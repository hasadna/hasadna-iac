resource "kamatera_server" "k972il_cluster2_management" {
  name = "k972il-cluster2-management"
  datacenter_id = "IL"
  cpu_type = "B"
  cpu_cores = 2
  ram_mb = 4096
  disk_sizes_gb = [100]
  billing_cycle = "hourly"
  image_id = local.kamatera_image_israel_ubuntu_1804_id

  network {
    name = "wan"
  }

  network {
    name = kamatera_network.k972il_cluster.full_name
    ip = "172.16.0.2"
  }

  lifecycle {
    ignore_changes = [image_id, power_on]
  }
}

resource "cloudflare_record" "k972il_rancher" {
  zone_id = data.cloudflare_zone.domain_infra_1.id
  name    = "k972il-rancher"
  value   = kamatera_server.k972il_cluster2_management.public_ips[0]
  type    = "A"
  ttl     = 120
  allow_overwrite = false
}

resource null_resource "k972il_cluster2_management_ssh_access_point" {
  depends_on = [kamatera_server.k972il_cluster2_management, null_resource.hasadna_ssh_access_point_provision]
  triggers = {
    authorized_keys = local.hasadna_authorized_keys
    version = 2
  }
  provisioner "remote-exec" {
    connection {
      host        = kamatera_server.hasadna_ssh_access_point.public_ips[0]
      private_key = var.ssh_private_key
      port        = var.hasadna_ssh_access_point_ssh_port
    }
    inline = [
      <<EOF
if ! cat .ssh/config | grep "Host k972il-management"; then
echo "
Host k972il-management
  HostName ${kamatera_server.k972il_cluster2_management.public_ips[0]}
  User root
"
fi &&\
scp .ssh/authorized_keys k972il-management:.ssh/authorized_keys &&\
ssh k972il-management "
ufw --force reset &&\
ufw default allow outgoing &&\
ufw default allow incoming &&\
ufw default deny routed &&\
ufw allow in from ${kamatera_server.k972il_cluster2_management.public_ips[0]} to any &&\
ufw allow in from ${kamatera_server.k972il_jenkins.public_ips[0]} to any &&\
ufw allow in from ${kamatera_server.hasadna_ssh_access_point.public_ips[0]} to any &&\
ufw deny in on eth0 to any port 22 &&\
ufw --force enable
"
EOF
    ]
  }
}

resource null_resource "k972il_cluster2_management_prom_node_exporter" {
  depends_on = [kamatera_server.k972il_cluster2_management, null_resource.hasadna_ssh_access_point_provision]
  triggers = {
    version = 1
  }
  provisioner "remote-exec" {
    connection {
      host        = kamatera_server.hasadna_ssh_access_point.public_ips[0]
      private_key = var.ssh_private_key
      port        = var.hasadna_ssh_access_point_ssh_port
    }
    inline = [
      <<EOF
ssh k972il-management "
docker rm -f prom-node-exporter
docker run -d --name prom-node-exporter \
  -v /proc:/host/proc -v /sys:/host/sys -v /:/host --net=host --restart unless-stopped \
  rancher/prom-node-exporter:v0.17.0 --web.listen-address=0.0.0.0:9796 --path.procfs=/host/proc \
    --path.sysfs=/host/sys --path.rootfs=/host --collector.arp \
    --collector.bcache --collector.bonding --no-collector.buddyinfo --collector.conntrack --collector.cpu --collector.diskstats \
    --no-collector.drbd --collector.edac --collector.entropy --collector.filefd --collector.filesystem --collector.hwmon \
    --collector.infiniband --no-collector.interrupts --collector.ipvs --no-collector.ksmd --collector.loadavg --no-collector.logind \
    --collector.mdadm --collector.meminfo --no-collector.meminfo_numa --no-collector.mountstats --collector.netdev --collector.netstat \
    --no-collector.nfs --no-collector.nfsd --no-collector.ntp --no-collector.processes --no-collector.qdisc --no-collector.runit \
    --collector.sockstat --collector.stat --no-collector.supervisord --no-collector.systemd --no-collector.tcpstat --collector.textfile \
    --collector.time     --collector.timex --collector.uname --collector.vmstat --no-collector.wifi --collector.xfs --collector.zfs
"
EOF
    ]
  }
}

output "rancher_ip" {
  value = kamatera_server.k972il_cluster2_management.public_ips[0]
}
