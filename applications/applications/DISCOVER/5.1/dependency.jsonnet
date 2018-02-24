# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local localcranVersion = "5.1";

  local _hdfsModuleName = "hdfs";
  local _yarnModuleName = "yarn";
  local _localcranModuleName = "localcran";
  local _discoverModuleName = "discover";

  //-------------------
  // Dependent modules
  //-------------------

  local localcran = t.createInstance(_localcranModuleName, config, localcranVersion) +
    r.moduleResource(_localcranModuleName, config);

  local discover = t.createInstance(_discoverModuleName, config, appVersion) +
    r.moduleResource(_discoverModuleName, config) +
    {
      dependencies: [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _yarnModuleName,
        name: _yarnModuleName,
      }, {
        moduleName: _localcranModuleName,
        name: appName + "-" +  _localcranModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [discover, localcran],
  }
