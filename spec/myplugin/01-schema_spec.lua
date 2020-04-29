local PLUGIN_NAME = "sritestplugin"

-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end

describe(PLUGIN_NAME .. ": (schema)", function()

  it("validates successfully when all the schema fields are supplied correctly", function()
    local ok, err = validate({
        europe_upstream_service = "some-service-1",
        italy_upstream_service = "some-service-2",
        italy_header_rules = {"X-Country=Italy"},
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("does not accept identical europe_upstream_service and italy_upstream_service", function()
    local ok, err = validate({
      europe_upstream_service = "some-service-1",
      italy_upstream_service = "some-service-1",
      italy_header_rules = {"X-Country=Italy"},
    })

    assert.is_same({
      ["config"] = {
        ["@entity"] = {
          [1] = "values of these fields must be distinct: 'europe_upstream_service', 'italy_upstream_service'"
        }
      }
    }, err)
    assert.is_falsy(ok)
  end)

  it("does not accept invalid rules for italy_header_rules", function()
    local ok, err = validate({
      europe_upstream_service = "some-service-1",
      italy_upstream_service = "some-service-2",
      italy_header_rules = {"X-Country=Usa"},
    })

    assert.is_same({
      ["config"] = {
        ["italy_header_rules"] = {
          [1] = "expected one of: X-Country=Italy, X-Regione=Abruzzo"
        }
      }
    }, err)
    assert.is_falsy(ok)
  end)

  it("does not accept empty rules for italy_header_rules", function()
    local ok, err = validate({
      europe_upstream_service = "some-service-1",
      italy_upstream_service = "some-service-2",
    })

    assert.is_same({
      ["config"] = {
        ["italy_header_rules"] = "required field missing"
      }
    }, err)
    assert.is_falsy(ok)
  end)

end)
