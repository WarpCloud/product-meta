# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local zkVersion = "5.0";

  local _zkModuleName = "zookeeper";
  local _hdfsModuleName = "hdfs";

  //-------------------
  // Dependent modules
  //-------------------

  local zookeeper = t.createInstance(_zkModuleName, config, zkVersion) +
    r.moduleResource(_zkModuleName, config);

  local hdfs = t.createInstance(_hdfsModuleName, config, appVersion) +
    r.moduleResource(_hdfsModuleName, config) +
    {
      dependencies: [{
        moduleName: _zkModuleName,
        name: appName + "-" + _zkModuleName,
      }],
    };

  local TCU = {
    [_hdfsModuleName]: r.moduleTCU(_hdfsModuleName, config),
    [_zkModuleName]: r.moduleTCU(_zkModuleName, config),
  };

  t.getDefaultSettings(config) + {
    instance_list: [zookeeper, hdfs],
    TCU: TCU,
  }
