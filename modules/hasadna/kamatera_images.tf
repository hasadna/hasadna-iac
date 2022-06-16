data "kamatera_image" "israel_ubuntu_1804" {
  datacenter_id = data.kamatera_datacenter.israel.id
  os = "Ubuntu"
  code = "18.04 64bit"
}
