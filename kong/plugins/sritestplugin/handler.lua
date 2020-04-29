
local plugin = {
  PRIORITY = 1000,
  VERSION = "0.1",
}

function plugin:access(plugin_conf)

  local headers = kong.request.get_headers()
  local italy_header_matched = 0

  for i = 1, #plugin_conf.italy_header_rules do
    local header_rule = plugin_conf.italy_header_rules[i]

    local header_name, header_value = string.match(header_rule, "(.*)=(.*)")
    local incoming_header_value = headers[header_name]

    if incoming_header_value and string.lower(incoming_header_value) == string.lower(header_value) then
      italy_header_matched = italy_header_matched + 1
    else
      break
    end
  end

  if italy_header_matched == #plugin_conf.italy_header_rules then
    kong.log.info("routing italy cluster")
    kong.service.set_upstream(plugin_conf.italy_upstream_service)
  else
    kong.log.info("routing europe cluster")
    kong.service.set_upstream(plugin_conf.europe_upstream_service)
  end
end

return plugin
