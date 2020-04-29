Kong plugin proxy
=================

This repository contains a very simple Kong plugin that will route to different destination based on presense of an header

Uses https://github.com/Kong/kong-vagrant as the development environment

Some useful commands below when using this plugin

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

