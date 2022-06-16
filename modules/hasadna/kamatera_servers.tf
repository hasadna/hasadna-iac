resource "kamatera_server" "hasadna_nfs1" {
  name = "hasadna-nfs1"
  datacenter_id = data.kamatera_datacenter.israel.id
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