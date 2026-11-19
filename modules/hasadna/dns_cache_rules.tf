# The zone's cache rules. Cloudflare allows one ruleset per phase per zone, so any
# other hostname's cache rule belongs in this resource too.
resource "cloudflare_ruleset" "hasadna_org_il_cache" {
  zone_id = data.cloudflare_zone.hasadna_org_il.zone_id
  name    = "hasadna.org.il cache rules"
  kind    = "zone"
  phase   = "http_request_cache_settings"
  rules = [
    {
      # By default Cloudflare caches only static file extensions, never an API's JSON.
      # bypass_by_default caches exactly what the origin marks with Cache-Control and
      # nothing else: without it, an unmarked 200 would be held for 120 minutes.
      description = "open-bus-api: cache what the origin marks cacheable"
      expression  = "(http.host eq \"open-bus-api.${data.cloudflare_zone.hasadna_org_il.name}\")"
      action      = "set_cache_settings"
      action_parameters = {
        cache = true
        edge_ttl = {
          mode = "bypass_by_default"
        }
        browser_ttl = {
          mode = "respect_origin"
        }
      }
      enabled = true
    },
  ]
}
