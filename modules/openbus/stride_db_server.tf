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

resource "cloudflare_dns_record" "hasadna_stride_db" {
  zone_id = var.cloudflare_zone_hasadna_org_il.zone_id
  name    = "open-bus-stride-db.${var.cloudflare_zone_hasadna_org_il.name}"
  content = kamatera_server.hasadna_stride_db.public_ips[0]
  type    = "A"
  ttl = 1
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

## increase stack depth
# nano /etc/security/limits.conf
#   postgres - stack 32768
#   * - stack 32768
# nano /etc/systemd/system/postgresql@14-main.service.d/override.conf
#   [Service]
#   LimitSTACK=33554432
# nano /etc/postgresql/14/main/postgresql.conf
#   max_stack_depth = 16MB

## Add Swap
# fallocate -l 32G /swapfile
# chmod 600 /swapfile
# mkswap /swapfile
# echo '/swapfile none swap sw 0 0' >> /etc/fstab
# swapon -a
# swapon --show
# free -h

## enable query logging
# su -l postgres
# psql
# ALTER SYSTEM SET logging_collector = on;
# ALTER SYSTEM SET log_destination = 'csvlog';
# ALTER SYSTEM SET log_line_prefix = '%m [%p] user=%u db=%d app=%a client=%r ';
# ALTER SYSTEM SET log_connections = on;
# ALTER SYSTEM SET log_disconnections = on;
# ALTER SYSTEM SET log_min_duration_statement = '10s';
# ALTER SYSTEM SET log_rotation_age = '14d';
# ALTER SYSTEM SET log_rotation_size = '2000MB';
# ALTER SYSTEM SET log_truncate_on_rotation = on;
# systemctl restart postgresql
