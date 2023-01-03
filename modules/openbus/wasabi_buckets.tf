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

# sync from digital ocean to wasabi:
# * create EC2 micro instance in Paris eu-west-3 (same region as the wasabi buckets)
# * download minio client binary (mc)
# * add aliases:
#   * ./mc alias set wa https://s3.eu-west-2.wasabisys.com ACCESS_KEY SECRET
#   * ./mc alias set do https://ams3.digitaloceanspaces.com ACCESS_KEY SECRET
# * sync:
#   * ./mc mirror do/obus-do1/ wa/obus-do1/
#   * ./mc mirror do/obus-do2/ wa/obus-do2/
