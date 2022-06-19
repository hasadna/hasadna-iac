resource "kamatera_server" "k972il_jenkins" {
  name = "k972il-jenkins"
  datacenter_id = "IL"
  cpu_type = "B"
  cpu_cores = 2
  ram_mb = 8192
  disk_sizes_gb = [100]
  billing_cycle = "monthly"
  image_id = data.kamatera_image.israel_ubuntu_1804.id

  network {
    name = "wan"
  }
}

resource null_resource "k972il_jenkins_ssh_access_point" {
  depends_on = [kamatera_server.k972il_jenkins, null_resource.hasadna_ssh_access_point_provision]
  triggers = {
    authorized_keys = local.hasadna_authorized_keys
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
if ! cat .ssh/config | grep "Host k972il-jenkins"; then
echo "
Host k972il-jenkins
  HostName ${kamatera_server.k972il_jenkins.public_ips[0]}
  User root
" >> .ssh/config
fi &&\
scp .ssh/authorized_keys k972il-jenkins:.ssh/authorized_keys &&\
ssh k972il-jenkins "
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
