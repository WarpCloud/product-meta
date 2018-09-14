# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local zkVersion = "6.0";

  local _zkModuleName = "zookeeper";
  local _hdfsModuleName = "hdfs";

  //-------------------
  // Dependent modules
  //-------------------

  local zookeeper = t.createInstance(_zkModuleName, config, zkVersion) +
    t.moduleResource(_zkModuleName, r.__moduleResourceRaw, config);

  local hdfs = t.createInstance(_hdfsModuleName, config, appVersion) +
    t.moduleResource(_hdfsModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _zkModuleName,
        name: appName + "-" + _zkModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [zookeeper, hdfs],
  }
