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
    r.moduleResource(_kongModuleName, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  local kongdashboard = t.createInstance(_kongdashboardModuleName, config, kongdashboardVersion) +
    r.moduleResource(_kongdashboardModuleName, config);

  t.getDefaultSettings(config) + {
    instance_list: [kong, kongdashboard],
  }
