# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local yarnVersion = "5.2";

  local _hdfsModuleName = "hdfs";
  local _inceptorModuleName = "inceptor";
  local _yarnModuleName = "yarn";
  local _zkModuleName = "zookeeper";
  local _hyperbaseModuleName = "hyperbase";

  //-------------------
  // Dependent modules
  //-------------------

  local hyperbase = t.createInstance(_hyperbaseModuleName, config, appVersion) +
    t.moduleResource(_hyperbaseModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _yarnModuleName,
        name: appName + "-" + _yarnModuleName,
      }, {
        moduleName: _zkModuleName,
        name: _hdfsModuleName + "-" + _zkModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [hyperbase],
  }
