# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local kongdashboardVersion = "1.1";

  local _kongModuleName = "kong";
  local _kongdashboardModuleName = "kong-dashboard";

  local _txsqlModuleName = "txsql";

  //-------------------
  // Dependent modules
  //-------------------

  local kong = t.createInstance(_kongModuleName, config, appVersion) +
    t.moduleResource(_kongModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  local kongdashboard = t.createInstance(_kongdashboardModuleName, config, kongdashboardVersion) +
    t.moduleResource(_kongdashboardModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _kongModuleName,
        name: appName + "-" +  _kongModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [kong, kongdashboard],
  }
