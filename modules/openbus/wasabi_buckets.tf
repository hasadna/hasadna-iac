module "wasabi_bucket_obus_do_1" {
  source = "../common/wasabi_bucket"
  name = "obus-do1"
  public_read_only = true
}

module "wasabi_bucket_obus_do_2" {
  source = "../common/wasabi_bucket"
  name = "obus-do2"
  public_read_only = true
}
