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
