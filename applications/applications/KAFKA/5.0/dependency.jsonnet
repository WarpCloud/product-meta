# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _zkModuleName = "zookeeper";
  local _kafkaModuleName = "kafka";

  //-------------------
  // Dependent modules
  //-------------------

  local kafka = t.createInstance(_kafkaModuleName, config, appVersion) +
    r.moduleResource(_kafkaModuleName, config) +
    {
      dependencies: [{
        moduleName: _zkModuleName,
        name: appName + "-" + _zkModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [kafka],
    TCU: {
      [_kafkaModuleName]: r.moduleTCU(_kafkaModuleName, config),
    },
  }
