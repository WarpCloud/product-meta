# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _filebeatModuleName = "filebeat";
  local _kafkaModuleName = "kafka";

  //-------------------
  // Dependent modules
  //-------------------

  local filebeat = t.createInstance(_filebeatModuleName, config, appVersion) +
    r.moduleResource(_filebeatModuleName, config) +
    {
      dependencies: [{
        moduleName: _kafkaModuleName,
        name: _kafkaModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [filebeat],
    TCU: {
      [_filebeatModuleName]: r.moduleTCU(_filebeatModuleName, config),
    },
  }
