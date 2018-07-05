# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _txsqlModuleName = "txsql";
  local _guardianModuleName = "guardian-cas";

  //-------------------
  // Dependent modules
  //-------------------

  local guardian = t.createInstance(_guardianModuleName, config, appVersion) +
    t.moduleResource(_guardianModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [guardian],
  }
