# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _moduleName = "gn-tenant";
  local _txsqlModuleName = "txsql";

  //-------------------
  // Dependent modules
  //-------------------

  local gn = t.createInstance(_moduleName, config, appVersion) +
    r.moduleResource(_moduleName, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [gn],
  }
