resource "kamatera_server" "hasadna_nfs1" {
  name = "hasadna-nfs1"
  datacenter_id = "IL"
  cpu_type = "T"
  cpu_cores = 2
  ram_mb = 2048
  disk_sizes_gb = [20, 200, 500]
  billing_cycle = "hourly"
  image_id = data.kamatera_image.israel_ubuntu_1804.id

  network {
    name = "wan"
  }

  network {
    name = kamatera_network.hasadna.full_name
    ip = "172.16.0.9"
  }

  lifecycle {
    ignore_changes = [
      image_id
    ]
  }
}

resource null_resource "hasadna_nfs1_ssh_access_point" {
  depends_on = [kamatera_server.hasadna_nfs1, null_resource.hasadna_ssh_access_point_provision]
  triggers = {
    authorized_keys = local.hasadna_authorized_keys
    version = 3
  }
  provisioner "remote-exec" {
    connection {
      host        = kamatera_server.hasadna_ssh_access_point.public_ips[0]
      private_key = var.ssh_private_key
      port        = var.hasadna_ssh_access_point_ssh_port
    }
    inline = [
      <<EOF
if ! cat .ssh/config | grep "Host hasadna-nfs1"; then
echo "
Host hasadna-nfs1
  HostName ${kamatera_server.hasadna_nfs1.private_ips[0]}
  User root
"
fi &&\
scp .ssh/authorized_keys hasadna-nfs1:.ssh/authorized_keys &&\
ssh hasadna-nfs1 "
ufw --force reset &&\
ufw default allow outgoing &&\
ufw default deny incoming &&\
ufw default deny routed &&\
ufw allow in from ${kamatera_server.k972il_cluster2_management.public_ips[0]} to any &&\
ufw allow in from ${kamatera_server.k972il_jenkins.public_ips[0]} to any &&\
ufw allow in from ${kamatera_server.hasadna_ssh_access_point.public_ips[0]} to any &&\
ufw allow in on eth1 to any &&\
ufw --force enable
"
EOF
    ]
  }
}

# Added delete-old-logs.py from this directory to home directory on hasadna-nfs1 server
# this script needs to run periodically to delete old airflow logs
# currently I run it manually when disk space is low:
# python3 delete-old-logs.py /srv/default2/openbus/airflow-home/logs 2023-09-12
# python3 delete-old-logs.py /srv/default2/oknesset/airflow-home/logs 2023-09-12
# python3 delete-old-logs.py /srv/default2/datacity/ckan-dgp-logs/airflow-logs 2023-09-12
