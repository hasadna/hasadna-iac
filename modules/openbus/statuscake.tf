locals {
  statuscake_checks = [
    {
      name     = "stride-api-siri-routes"
      url      = "https://open-bus-stride-api.hasadna.org.il/siri_routes/list"
      disabled = false
    },
    {
      name     = "stride-api-siri-vehicle-locations"
      url      = "https://open-bus-stride-api.hasadna.org.il/siri_vehicle_locations/list?order_by=id%20desc"
      disabled = false
    },
    {
      name     = "stride-api-gtfs-rides"
      url      = "https://open-bus-stride-api.hasadna.org.il/gtfs_rides/list?order_by=id%20desc"
      disabled = false
    }
  ]
}

resource "statuscake_uptime_check" "checks" {
  for_each       = { for site in local.statuscake_checks : site.name => site if !site.disabled }
  name           = each.key
  check_interval = 60 * 5 # every 5 minutes
  confirmation   = 3
  trigger_rate   = 5
  http_check {
    status_codes     = [204, 205, 206, 303, 400, 401, 403, 404, 405, 406, 408, 410, 413, 444, 429, 494, 495, 496, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 521, 522, 523, 524, 520, 598, 599]
    validate_ssl     = true
    follow_redirects = true
    timeout          = 40
    user_agent       = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 (hasadna-iac apps-sites statuscake)"
  }
  monitored_resource {
    address = each.value.url
  }
  contact_groups = ["35660"]  # DevOps contact group
}
