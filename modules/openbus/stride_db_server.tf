resource "kamatera_server" "hasadna_stride_db" {
  name = "hasadna-stride-db"
  datacenter_id = "IL"
  cpu_type = "B"
  cpu_cores = 6
  ram_mb = 32768
  disk_sizes_gb = [3000]
  billing_cycle = "monthly"
  image_id = "ubuntu"

  network {
    name = "wan"
  }

  network {
    name = "lan-82145-hasadna"
    ip = "172.16.0.16"
  }

  lifecycle {
    ignore_changes = [disk_sizes_gb]
  }
}

resource "cloudflare_record" "hasadna_stride_db" {
  zone_id = var.cloudflare_zone_hasadna_org_il.id
  name    = "open-bus-stride-db"
  value   = kamatera_server.hasadna_stride_db.public_ips[0]
  type    = "A"
}

resource null_resource "hasadna_stride_db_ssh_access_point" {
  depends_on = [kamatera_server.hasadna_stride_db, var.hasadna_ssh_access_point_provision]
  triggers = {
    authorized_keys = var.hasadna_authorized_keys
    version = 1
  }
  provisioner "remote-exec" {
    connection {
      host        = var.hasadna_ssh_access_point_public_ip
      private_key = var.ssh_private_key
      port        = var.hasadna_ssh_access_point_ssh_port
    }
    inline = [
      <<EOF
if ! cat .ssh/config | grep "Host stride-db"; then
echo "
Host stride-db
  HostName ${kamatera_server.hasadna_stride_db.public_ips[0]}
  User root
" >> .ssh/config
fi &&\
if ! cat .ssh/known_hosts | grep "^# stride-db"; then
  echo "# stride-db" >> .ssh/known_hosts &&\
  ssh-keyscan -H ${kamatera_server.hasadna_stride_db.public_ips[0]} >> .ssh/known_hosts
fi &&\
scp .ssh/authorized_keys stride-db:.ssh/authorized_keys &&\
ssh stride-db "
ufw --force reset &&\
ufw default allow outgoing &&\
ufw default allow incoming &&\
ufw default deny routed &&\
ufw allow in from ${var.hasadna_ssh_access_point_public_ip} to any &&\
ufw deny in on eth0 to any port 22 &&\
ufw --force enable
"
EOF
    ]
  }
}
