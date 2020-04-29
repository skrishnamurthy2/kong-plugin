local helpers = require "spec.helpers"

local PLUGIN_NAME = "sritestplugin"

local fixtures = {
  http_mock = {
    upstream_mtls = [[
      server {
          server_name europe.com;
          listen 10000;
          location = / {
              echo 'hello from europe cluster';
          }
        }
        server {
          server_name italy.com;
          listen 10001;
          location = / {
              echo 'hello from italy cluster';
          }
        }
  ]]
  },
}

for _, strategy in helpers.each_strategy() do
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })

      local upstream1 = assert(bp.upstreams:insert({
        name = "europe-cluster",
      }))

      local upstream2 = assert(bp.upstreams:insert({
        name = "italy-cluster",
      }))

      assert(bp.targets:insert({
        upstream = upstream1,
        target = "127.0.0.1:10000",
        weight = 100,
      }))
      assert(bp.targets:insert({
        upstream = upstream2,
        target = "127.0.0.1:10001",
        weight = 100,
      }))

      local service = bp.services:insert {
        name = "europe-service",
        host = "europe-cluster"
      }

      local route1 = bp.routes:insert({
        paths = { "/local" },
        service = service
      })
      -- add the plugin
      bp.plugins:insert {
        name = PLUGIN_NAME,
        service = { id = service.id },
        config = {
          europe_upstream_service = "europe-cluster",
          italy_upstream_service = "italy-cluster",
          italy_header_rules = {"X-Country=Italy", "X-Regione=Abruzzo"}
        },
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
      },nil, nil, fixtures))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)

    describe("Request routing", function()
      it("routes to europe cluster when there is no override headers", function()
        local r = client:get("/local", {})
        -- validate that the request succeeded, response status 200
        local body = assert.response(r).has.status(200)
        assert.equal("hello from europe cluster", body)
      end)
      
      it("routes to europe cluster when there is only partial override headers matched", function()
        local r = client:get("/local", {
          headers = {
            ["X-Country"] = "Italy",
          }
        })
        -- validate that the request succeeded, response status 200
        local body = assert.response(r).has.status(200)
        assert.equal("hello from europe cluster", body)
      end)

      it("routes to italy cluster when there is override headers", function()
        local r = client:get("/local", {
          headers = {
            ["X-Country"] = "Italy",
            ["X-Regione"] = "Abruzzo"
          }
        })
        -- validate that the request succeeded, response status 200
        local body = assert.response(r).has.status(200)
        assert.equal("hello from italy cluster", body)
      end)

      it("routes to italy cluster when override headers are in lower case", function()
        local r = client:get("/local", {
          headers = {
            ["X-country"] = "italy",
            ["X-regione"] = "abruzzo"
          }
        })
        -- validate that the request succeeded, response status 200
        local body = assert.response(r).has.status(200)
        assert.equal("hello from italy cluster", body)
      end)

    end)

  end)
end
