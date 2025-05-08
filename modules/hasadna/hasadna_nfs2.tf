resource "kamatera_server" "hasadna_nfs2" {
  name = "hasadna-nfs2"
  datacenter_id = "IL"
  cpu_type = "B"
  cpu_cores = 4
  ram_mb = 8192
  disk_sizes_gb = [50, 200, 1500]
  billing_cycle = "monthly"
  image_id = local.kamatera_image_israel_ubuntu_2404_id

  network {
    name = "wan"
    ip = "auto"
  }

  network {
    name = kamatera_network.hasadna.full_name
    ip = "172.16.0.9"
  }

  lifecycle {
    ignore_changes = [
      image_id,
      network
    ]
  }
}

# copy authorized keys from ssh access point to the this server authorized keys
# mkdir -p /srv/default
# mkdir -p /mnt/sdb3
# lsblk -f
# echo UUID=ca5b6eec-9935-4392-b385-e59d1d166cf4  /srv/default  ext4  defaults,noatime  0 2 >> /etc/fstab
# echo UUID=c837ed13-738e-11e8-9c98-00505607b87c  /mnt/sdb3     ext4  defaults,noatime  0 2 >> /etc/fstab
# systemctl daemon-reload
# mount -a
# mkdir -p /export
# mount --bind /srv/default /export
# echo '/srv/default  /export  none  bind  0 0' | sudo tee -a /etc/fstab
# mkdir -p /export/mnt/sdb3
# mount --bind /mnt/sdb3 /export/mnt/sdb3
# echo '/mnt/sdb3  /export/mnt/sdb3  none  bind  0 0' | sudo tee -a /etc/fstab
# systemctl daemon-reload
# mount -a
# apt update
# apt install -y nfs-kernel-server
# echo '/export 172.16.0.0/16(rw,sync,fsid=0,crossmnt,no_subtree_check,sec=sys,no_root_squash)' >> /etc/exports
# exportfs -ra
# systemctl restart nfs-server
# systemctl enable nfs-server
# ufw --force reset
# ufw default allow outgoing
# ufw default deny incoming
# ufw default deny routed
# ufw allow in from ${kamatera_server.k972il_cluster2_management.public_ips[0]} to any
# ufw allow in from ${kamatera_server.k972il_jenkins.public_ips[0]} to any
# ufw allow in from ${kamatera_server.hasadna_ssh_access_point.public_ips[0]} to any
# ufw allow in on eth1 to any
# ufw --force enable

# Add delete-old-logs.py from this directory to home directory on hasadna-nfs1 server
# this script needs to run periodically to delete old airflow logs
# currently I run it manually when disk space is low, but there is also jenkins job
# python3 delete-old-logs.py /srv/default2/openbus/airflow-home/logs 2023-09-12
# python3 delete-old-logs.py /srv/default2/oknesset/airflow-home/logs 2023-09-12
# python3 delete-old-logs.py /srv/default2/datacity/ckan-dgp-logs/airflow-logs 2023-09-12
