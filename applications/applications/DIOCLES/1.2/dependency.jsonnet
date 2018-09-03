# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _dioclesModuleName = "diocles";
  local _guardianModuleName = "guardian-cas";

  //-------------------
  // Dependent modules
  //-------------------

  local diocles = t.createInstance(_dioclesModuleName, config, appVersion) +
  t.moduleResource(_dioclesModuleName, r.__moduleResourceRaw, config) +
    {
     dependencies: [{
        moduleName: _guardianModuleName,
        name: _guardianModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [diocles],
  }
