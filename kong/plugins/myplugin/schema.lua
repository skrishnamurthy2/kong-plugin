local typedefs = require "kong.db.schema.typedefs"

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

-- vagrant up
-- vagrant ssh
-- vagrant destroy
-- cd /kong
-- export KONG_PLUGINS=bundled,myplugin
-- bin/kong migrations bootstrap
-- bin/kong start

-- curl -i -X POST --url http://localhost:8001/upstreams --data 'name=europe-cluster'
-- curl -i -X POST --url http://localhost:8001/upstreams --data 'name=italy-cluster'

-- curl -i -X POST --url http://localhost:8001/upstreams/europe-cluster/targets --data 'target=mockbin.org:80' --data 'weight=100'
-- curl -i -X POST --url http://localhost:8001/upstreams/italy-cluster/targets --data 'target=httpbin.org:80' --data 'weight=100'

-- curl -i -X POST http://localhost:8001/services/   --data 'name=europe-service' --data 'host=europe-cluster'

-- curl -X POST http://localhost:8001/services/europe-service/routes/ --data "paths[]=/local"

-- curl -X POST http://localhost:8001/services/europe-service/plugins
-- -d "name=myplugin" \
-- -d "config.europe_upstream_service=europe-cluster" \
-- -d "config.italy_upstream_service=italy-cluster" \
-- -d "config.italy_header_rules[]=X-Country=Italy" \
-- -d "config.italy_header_rules[]=X-Regione=Abruzzo" \

-- curl -i -X GET   --url http://localhost:8000/local   
-- curl -i -X GET   --url http://localhost:8000/local --header 'X-Country: Italy' --header 'X-Regione: Abruzzo'


-- cat /kong/servroot/logs/error.log
-- make dev
-- bin/busted -v -o gtest /kong-plugin/spec