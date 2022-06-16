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
}

resource "kamatera_server" "hasadna_ssh_access_point" {
  name = "hasadna-ssh-access-point"
  datacenter_id = "IL"
  cpu_type = "A"
  cpu_cores = 1
  ram_mb = 512
  disk_sizes_gb = [5]
  billing_cycle = "monthly"
  image_id = data.kamatera_image.israel_ubuntu_1804.id

  network {
    name = "wan"
  }

  network {
    name = kamatera_network.hasadna.full_name
    ip = "172.16.0.7"
  }
}

resource "kamatera_server" "k972il_cluster2_management" {
  name = "k972il-cluster2-management"
  datacenter_id = "IL"
  cpu_type = "B"
  cpu_cores = 2
  ram_mb = 4096
  disk_sizes_gb = [100]
  billing_cycle = "hourly"
  image_id = data.kamatera_image.israel_ubuntu_1804.id

  network {
    name = "wan"
  }

  network {
    name = kamatera_network.k972il_cluster.full_name
    ip = "172.16.0.2"
  }
}

resource "kamatera_server" "k972il_jenkins" {
  name = "k972il-jenkins"
  datacenter_id = "IL"
  cpu_type = "B"
  cpu_cores = 2
  ram_mb = 4096
  disk_sizes_gb = [100]
  billing_cycle = "monthly"
  image_id = data.kamatera_image.israel_ubuntu_1804.id

  network {
    name = "wan"
  }
}
