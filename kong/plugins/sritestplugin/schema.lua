-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

return {
  name = plugin_name,
  fields = {
    { 
      config = {
        type = "record",
        fields = {
          {
            europe_upstream_service = {
              type = "string",
              required = true,
            },
          },
          {
            italy_upstream_service = {
              type = "string",
              required = true,
            },
          },
          {
            italy_header_rules = {
              type = "array", 
              required = true,
              elements = {type = "string",one_of = {"X-Country=Italy", "X-Regione=Abruzzo"}}
            }
          }
        },
        entity_checks = {
          { distinct = { "europe_upstream_service", "italy_upstream_service"} },
        }
      }
    }
  }
}
