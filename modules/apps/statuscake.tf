locals {
  sites = [
    {
      name     = "budgetism"
      url      = "https://act.obudget.org"
      disabled = false
    },
    {
      name     = "socialpro"
      url      = "https://www.socialpro.org.il/"
      disabled = false
    },
    {
      name     = "budgetkey"
      url      = "https://next.obudget.org/"
      disabled = false
    },
    {
      name     = "digital-forest-cards"
      url      = "https://cards.digital-forest.org.il/"
      disabled = false
    },
  ]
}

resource "statuscake_uptime_check" "sites" {
  for_each       = { for site in local.sites : site.name => site if !site.disabled }
  name           = each.key
  tags           = ["hasadna-iac", "apps-sites"]
  check_interval = 60 * 30 # every 30 minutes
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
  contact_groups = [234311]
}
