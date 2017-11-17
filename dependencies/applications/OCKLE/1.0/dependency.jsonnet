# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _txsqlModuleName = "txsql";
  local _ockleModuleName = "ockle";

  //-------------------
  // Dependent modules
  //-------------------

  local ockle = t.createInstance(_ockleModuleName, config, appVersion) +
    r.moduleResource(_ockleModuleName, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [ockle],
    TCU: {
      [_ockleModuleName]: r.moduleTCU(_ockleModuleName, config),
    },
  }
