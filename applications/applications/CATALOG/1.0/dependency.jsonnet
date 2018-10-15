# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _catalogModuleName = "catalog";
  local _guardianModuleName = "guardian-cas";
  local _txsqlModuleName = "txsql";
  local _hyperbaseModuleName = "hyperbase";
  local _kafkaModuleName = "kafka";
  local _searchModuleName = "elasticsearch";

  //-------------------
  // Dependent modules
  //-------------------

  local catalog = t.createInstance(_catalogModuleName, config, appVersion) +
  t.moduleResource(_catalogModuleName, r.__moduleResourceRaw, config) +
    {
     dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      },{
        moduleName: _hyperbaseModuleName,
        name: _hyperbaseModuleName,
      }, {
        moduleName: _kafkaModuleName,
        name: _kafkaModuleName,
      }, {
        moduleName: _searchModuleName,
        name: _searchModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [catalog],
  }
