# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _zkModuleName = "zookeeper";
  local _hdfsModuleName = "hdfs";
  local _yarnModuleName = "yarn";

  //-------------------
  // Dependent modules
  //-------------------

  local yarn = t.createInstance(_yarnModuleName, config, appVersion) +
    r.moduleResource(_yarnModuleName, config) +
    {
      dependencies: [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _zkModuleName,
        name: _hdfsModuleName + "-" + _zkModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [yarn],
    TCU: {
      [_yarnModuleName]: r.moduleTCU(_yarnModuleName, config),
    },
  }
