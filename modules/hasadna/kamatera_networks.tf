resource "kamatera_network" "hasadna" {
  datacenter_id = "IL"
  name = "hasadna"

  subnet {
    ip = "172.16.0.0"
    bit = 23
  }
}

resource "kamatera_network" "k972il_cluster" {
  datacenter_id = "IL"
  name = "k972il-cluster"

  subnet {
    ip = "172.16.0.0"
    bit = 23
  }
}

