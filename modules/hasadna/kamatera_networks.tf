resource "kamatera_network" "hasadna" {
  datacenter_id = data.kamatera_datacenter.israel.id
  name = "hasadna"

  subnet {
    ip = "172.16.0.0"
    bit = 23
  }
}
