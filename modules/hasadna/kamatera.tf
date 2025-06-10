# data "kamatera_image" "israel_ubuntu_1804" {
#   datacenter_id = "IL"
#   os = "Ubuntu"
#   code = "18.04 64bit"
# }
# data "kamatera_image" "israel_ubuntu_2404" {
#   datacenter_id = "IL"
#   os = "Ubuntu"
#   code = "24.04 64bit"
# }
locals {
  kamatera_image_israel_ubuntu_1804_id = "IL:6000C2981f160a3b548a6ac00528bcf1"
  kamatera_image_israel_ubuntu_2404_id = "IL:6000C29549da189eaef6ea8a31001a34"
}

resource "kamatera_network" "hasadna" {
  datacenter_id = "IL"
  name = "hasadna"

  subnet {
    ip = "172.16.0.0"
    bit = 23
  }
}
