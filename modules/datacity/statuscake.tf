resource "statuscake_uptime_check" "apps" {
    for_each = {for site in local.sites: site.name => site if !site.disabled}
    name = "datacity-${each.key}"
    tags = ["hasadna-iac", "datacity", "datacity-${each.key}"]
    check_interval = 60
    confirmation = 3
    http_check {
        status_codes = [204, 205, 206, 303, 400, 401, 403, 404, 405, 406, 408, 410, 413, 444, 429, 494, 495, 496, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 521, 522, 523, 524, 520, 598, 599]
        validate_ssl = true
        follow_redirects = true
        timeout = 15
    }
    monitored_resource {
        address = each.value.url
    }
    contact_groups = [234311]
}

resource "statuscake_uptime_check" "datasets_count" {
    for_each = {for site in local.sites: site.name => site if !site.disabled}
    name = "datacity-${each.key}-datasets-count"
    tags = ["hasadna-iac", "datacity", "datacity-${each.key}", "datasets-count"]
    check_interval = 60
    confirmation = 3
    http_check {
        status_codes = [204, 205, 206, 303, 400, 401, 403, 404, 405, 406, 408, 410, 413, 444, 429, 494, 495, 496, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 521, 522, 523, 524, 520, 598, 599]
        validate_ssl = true
        follow_redirects = true
        timeout = 15
        content_matchers {
            content = "\"count\": 0"
            matcher = "NOT_CONTAINS_STRING"
        }
    }
    monitored_resource {
        address = "${each.value.url}/api/3/action/package_search?rows=1"
    }
    contact_groups = [234311]
}
