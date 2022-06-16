resource "kamatera_server" "hasadna_stride_db" {
  name = "hasadna-stride-db"
  datacenter_id = "IL"
  cpu_type = "B"
  cpu_cores = 6
  ram_mb = 32768
  disk_sizes_gb = [1500]
  billing_cycle = "monthly"
  image_id = "ubuntu"

  network {
    name = "wan"
  }

  network {
    name = "lan-82145-hasadna"
    ip = "172.16.0.16"
  }
}
