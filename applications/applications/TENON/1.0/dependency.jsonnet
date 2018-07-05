# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local gondarVersion = "1.0";

  local _kafkaModuleName = "kafka";
  local _gondarModuleName = "gondar";
  local _txsqlModuleName = "txsql";
  local _tenonModuleName = "tenon";

  //-------------------
  // Dependent modules
  //-------------------

  local gondar = t.createInstance(_gondarModuleName, config, gondarVersion) +
    t.moduleResource(_gondarModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      },{
        moduleName: _kafkaModuleName,
        name: _kafkaModuleName,
      }],
    };

  local tenon = t.createInstance(_tenonModuleName, config, appVersion) +
    t.moduleResource(_tenonModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _kafkaModuleName,
        name: _kafkaModuleName,
      }, {
        moduleName: _gondarModuleName,
        name: appName + "-" + _gondarModuleName,
      },{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [gondar, tenon],
  }
