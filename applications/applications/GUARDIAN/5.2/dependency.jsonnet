# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local casVersion = "1.1";

  local _txsqlModuleName = "txsql";
  local _casModuleName = "cas";
  local _guardianModuleName = "guardian";

  //-------------------
  // Dependent modules
  //-------------------

  local cas = t.createInstance(_casModuleName, config, casVersion) +
    r.moduleResource(_casModuleName, config) +
    {
      dependencies: [{
        moduleName: _guardianModuleName,
        name: appName + "-" + _guardianModuleName,
      },{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  local guardian = t.createInstance(_guardianModuleName, config, appVersion) +
    r.moduleResource(_guardianModuleName, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [guardian, cas],
  }
